/**
 * Replay Last Tool Call
 *
 * Re-runs the most recent tool call after applying a small JSON Patch
 * (RFC 6902) to its recorded arguments, then executes the underlying tool
 * again with the patched arguments.
 *
 * Motivation: when the model wants to redo a tool call with a minor tweak
 * (drop an accidental key, flip a flag, fix one path) it would otherwise
 * have to restate the entire call. For a large `write` body or a long
 * `bash` command that is expensive in output tokens. A patch expresses the
 * delta in a few tokens instead.
 *
 * The tool inspects the current branch for the last assistant tool call
 * that is not itself a `replay_tool_call`, reconstructs the target tool's
 * definition (built-in tools via their create*ToolDefinition factories,
 * extension tools via the live registry), applies the patch to the stored
 * arguments, validates against the target's schema, and executes it. The
 * result is returned as this tool's own result, so it renders and feeds
 * back into the conversation like a normal tool call.
 *
 * Patch dialect: a compact subset of RFC 6902 with ops add/remove/replace.
 * `path` is a JSON Pointer (e.g. "/timeout", "/edits/0/oldText"). This is
 * enough for the common cases (remove a key, change a scalar, edit one
 * element) while staying trivial to reason about. `move`/`copy`/`test` are
 * intentionally omitted; they are rarely useful for this workflow and add
 * surface area.
 */

import {
	createBashToolDefinition,
	createEditToolDefinition,
	createFindToolDefinition,
	createGrepToolDefinition,
	createLsToolDefinition,
	createReadToolDefinition,
	createWriteToolDefinition,
	type ExtensionAPI,
	type ExtensionContext,
	type ToolDefinition,
} from "@earendil-works/pi-coding-agent";
import { StringEnum } from "@earendil-works/pi-ai";
import { Value } from "typebox/value";
import { Type } from "typebox";

const TOOL_NAME = "replay_tool_call";

/**
 * A recorded tool call recovered from the session branch: the assistant's
 * declared tool name plus the arguments it sent.
 */
interface RecordedCall {
	name: string;
	arguments: Record<string, unknown>;
}

/**
 * Walk the current branch backwards and return the most recent assistant
 * tool call, skipping this extension's own tool so a replay never targets
 * a prior replay (which would double-apply intent and confuse the model).
 */
function findLastToolCall(ctx: ExtensionContext): RecordedCall | undefined {
	const branch = ctx.sessionManager.getBranch();
	for (let i = branch.length - 1; i >= 0; i--) {
		const entry = branch[i];
		if (entry.type !== "message" || entry.message.role !== "assistant") continue;
		const content = entry.message.content;
		if (!Array.isArray(content)) continue;
		for (let j = content.length - 1; j >= 0; j--) {
			const part = content[j];
			if (part.type !== "toolCall") continue;
			if (part.name === TOOL_NAME) continue;
			return { name: part.name, arguments: { ...part.arguments } };
		}
	}
	return undefined;
}

/**
 * Reconstruct the ToolDefinition for a tool name so it can be executed
 * directly. Built-in tools are rebuilt from their factories bound to the
 * session cwd; anything else is looked up in the live tool registry via
 * pi.getAllTools()/getActiveTools() is not enough (that only yields
 * metadata), so we accept an extension-provided definition map.
 */
function builtinDefinition(
	name: string,
	cwd: string,
): ToolDefinition | undefined {
	switch (name) {
		case "bash":
			return createBashToolDefinition(cwd) as unknown as ToolDefinition;
		case "read":
			return createReadToolDefinition(cwd) as unknown as ToolDefinition;
		case "edit":
			return createEditToolDefinition(cwd) as unknown as ToolDefinition;
		case "write":
			return createWriteToolDefinition(cwd) as unknown as ToolDefinition;
		case "grep":
			return createGrepToolDefinition(cwd) as unknown as ToolDefinition;
		case "find":
			return createFindToolDefinition(cwd) as unknown as ToolDefinition;
		case "ls":
			return createLsToolDefinition(cwd) as unknown as ToolDefinition;
		default:
			return undefined;
	}
}

// --- Minimal RFC 6902 JSON Patch (add / remove / replace) ---------------

interface PatchOp {
	op: "add" | "remove" | "replace";
	path: string;
	value?: unknown;
}

/** Decode a single JSON Pointer reference token (~1 -> /, ~0 -> ~). */
function decodeToken(token: string): string {
	return token.replace(/~1/g, "/").replace(/~0/g, "~");
}

/** Split a JSON Pointer into its decoded reference tokens. */
function pointerTokens(pointer: string): string[] {
	if (pointer === "") return [];
	if (pointer[0] !== "/") {
		throw new Error(`Invalid JSON Pointer (must start with '/'): ${pointer}`);
	}
	return pointer.slice(1).split("/").map(decodeToken);
}

/**
 * Apply one op to `doc` in place and return the (possibly replaced) root.
 * Kept deliberately small: array indices are numeric strings, and "-"
 * appends to an array for `add`, mirroring RFC 6902.
 */
function applyOp(doc: unknown, op: PatchOp): unknown {
	const tokens = pointerTokens(op.path);

	if (tokens.length === 0) {
		// Whole-document replace/add; remove of root is meaningless here.
		if (op.op === "remove") {
			throw new Error("Cannot remove the whole document root");
		}
		return op.value;
	}

	// Navigate to the container that holds the final token.
	let parent: any = doc;
	for (let i = 0; i < tokens.length - 1; i++) {
		const key = tokens[i];
		if (parent == null || typeof parent !== "object") {
			throw new Error(`Path not found: ${op.path}`);
		}
		parent = Array.isArray(parent) ? parent[Number(key)] : parent[key];
	}
	if (parent == null || typeof parent !== "object") {
		throw new Error(`Path not found: ${op.path}`);
	}

	const last = tokens[tokens.length - 1];

	if (Array.isArray(parent)) {
		const idx = last === "-" ? parent.length : Number(last);
		if (!Number.isInteger(idx) || idx < 0) {
			throw new Error(`Invalid array index in path: ${op.path}`);
		}
		switch (op.op) {
			case "add":
				parent.splice(idx, 0, op.value);
				break;
			case "replace":
				if (idx >= parent.length) throw new Error(`Index out of range: ${op.path}`);
				parent[idx] = op.value;
				break;
			case "remove":
				if (idx >= parent.length) throw new Error(`Index out of range: ${op.path}`);
				parent.splice(idx, 1);
				break;
		}
	} else {
		switch (op.op) {
			case "add":
			case "replace":
				parent[last] = op.value;
				break;
			case "remove":
				delete parent[last];
				break;
		}
	}

	return doc;
}

/** Apply a patch to a deep copy of `args`, returning the patched object. */
function applyPatch(
	args: Record<string, unknown>,
	patch: PatchOp[],
): Record<string, unknown> {
	let doc: unknown = structuredClone(args);
	for (const op of patch) {
		doc = applyOp(doc, op);
	}
	if (doc == null || typeof doc !== "object" || Array.isArray(doc)) {
		throw new Error("Patched arguments must be a JSON object");
	}
	return doc as Record<string, unknown>;
}

// ------------------------------------------------------------------------

const patchOpSchema = Type.Object({
	op: StringEnum(["add", "remove", "replace"] as const, {
		description: "RFC 6902 operation",
	}),
	path: Type.String({
		description: 'JSON Pointer into the recorded arguments, e.g. "/timeout" or "/edits/0/oldText"',
	}),
	value: Type.Optional(
		Type.Any({ description: "New value for add/replace ops; omit for remove" }),
	),
});

const replaySchema = Type.Object({
	patch: Type.Array(patchOpSchema, {
		description:
			"JSON Patch (RFC 6902 subset: add/remove/replace) applied to the last tool call's arguments before re-executing it",
	}),
});

export default function (pi: ExtensionAPI): void {
	pi.registerTool({
		name: TOOL_NAME,
		label: "Replay Tool Call",
		description:
			"Re-run the most recent tool call after applying a JSON Patch (RFC 6902) to its " +
			"arguments. Use this to redo a call with a small edit instead of restating the whole " +
			"call: e.g. drop an accidental key with {op:\"remove\",path:\"/foo\"}, change a scalar " +
			"with {op:\"replace\",path:\"/timeout\",value:60}, or fix one element with " +
			"{op:\"replace\",path:\"/edits/0/oldText\",value:\"...\"}. Paths are JSON Pointers. " +
			"The patched call executes as the target tool and its result is returned here. " +
			"Prefer this over re-issuing large write/bash/edit calls to save output tokens.",
		promptSnippet:
			"Redo the previous tool call with a JSON Patch applied to its arguments (token-saving edit-and-rerun)",
		promptGuidelines: [
			"Use replay_tool_call to redo the previous tool call with a small change (remove/replace a " +
				"field) instead of re-emitting a large write, edit, or bash call verbatim.",
		],
		parameters: replaySchema,

		async execute(toolCallId, params, signal, onUpdate, ctx) {
			const last = findLastToolCall(ctx);
			if (!last) {
				throw new Error("No previous tool call found to replay");
			}

			const patched = applyPatch(last.arguments, params.patch as PatchOp[]);

			const definition =
				builtinDefinition(last.name, ctx.cwd) ??
				// Extension/custom tools: look up the live registered definition.
				(pi.getAllTools().find((t) => t.name === last.name)
					? await resolveRegisteredTool(pi, last.name)
					: undefined);

			if (!definition) {
				throw new Error(
					`Cannot replay tool "${last.name}": no executable definition available`,
				);
			}

			// Run any compatibility shim, then validate against the target schema
			// so a malformed patch fails here rather than deep inside the tool.
			const prepared = definition.prepareArguments
				? definition.prepareArguments(patched)
				: patched;
			if (!Value.Check(definition.parameters, prepared)) {
				const errors = [...Value.Errors(definition.parameters, prepared)]
					.slice(0, 5)
					.map((e) => `${e.path}: ${e.message}`)
					.join("; ");
				throw new Error(
					`Patched arguments do not satisfy ${last.name}'s schema: ${errors}`,
				);
			}

			return definition.execute(toolCallId, prepared, signal, onUpdate, ctx);
		},
	});
}

/**
 * Resolve a live extension/custom tool's executable definition. pi exposes
 * only metadata through getAllTools(); the executable definition lives on
 * the runner. We reach it through the same registry pi uses so custom tools
 * can also be replayed. Returns undefined if not resolvable.
 */
async function resolveRegisteredTool(
	pi: ExtensionAPI,
	name: string,
): Promise<ToolDefinition | undefined> {
	// The public API does not expose executable definitions for other
	// extensions' tools, so replay of custom tools is best-effort. If a
	// future pi version adds this, wire it here.
	const anyPi = pi as unknown as {
		getToolDefinition?: (n: string) => ToolDefinition | undefined;
	};
	return anyPi.getToolDefinition?.(name);
}
