/**
 * Edit Watcher Extension
 *
 * Watches files the agent writes/edits and notifies the agent when the user
 * modifies them externally.
 *
 * Strategy:
 *   - On `tool_call` for write/edit, add the path to `suppressed` and close
 *     its watcher.
 *   - On `tool_result`, remove it from `suppressed` and, unless the tool
 *     errored, mark it as `watched` and re-attach the watcher.
 *   - On `turn_end`, sweep any paths still in `suppressed` (their `tool_call`
 *     was blocked by another extension so `tool_result` never fired). Only
 *     re-attach watchers on paths that are in `watched` — paths whose very
 *     first write was blocked shouldn't be watched at all.
 *   - Accumulate externally modified paths in a Map so duplicates collapse.
 *   - After a successful agent write/edit, hash the file and remember it. At
 *     flush time, drop any pending modified paths whose current content
 *     matches that hash (e.g. user typed and then undid the change), so we
 *     don't pester the agent about a no-op edit.
 *   - Flush pending notices:
 *       - in `before_agent_start` via the `{ message }` return (zero lag for
 *         edits made before the user submitted their prompt),
 *       - in `turn_start` via `pi.sendMessage` for edits detected mid-agent.
 *
 * Known limitations:
 *   - Parallel write/edit tool calls on the same file in one assistant
 *     message can produce a false-positive notice: the first `tool_result`
 *     re-attaches a watcher while the second's write is still serialized
 *     behind pi's per-file mutation queue.
 *   - On macOS, atomic-rename saves sometimes emit only `change` events
 *     without a matching `rename`. The inode-based watcher silently dies and
 *     subsequent edits go undetected until the agent next writes that file.
 */

import * as crypto from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";
import {
	isEditToolResult,
	isToolCallEventType,
	isWriteToolResult,
	type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";

type ChangeKind = "modified" | "deleted";

export default function (pi: ExtensionAPI) {
	const watchers = new Map<string, fs.FSWatcher>();
	// Paths that have had at least one successful write/edit by the agent.
	const watched = new Set<string>();
	// Paths whose watcher is intentionally detached while the agent writes.
	const suppressed = new Set<string>();
	// Externally observed changes since last flush; dedup by path.
	const pending = new Map<string, ChangeKind>();
	// MD5 of file content immediately after the agent's last successful
	// write/edit. Used to suppress notices when the user reverts a change so
	// the file ends up byte-identical to what the agent wrote.
	const lastWrittenHash = new Map<string, string>();
	let cwd = process.cwd();
	let shuttingDown = false;

	function resolvePath(input: string): string {
		return path.resolve(cwd, input);
	}

	function hashFile(absPath: string): string | null {
		try {
			const content = fs.readFileSync(absPath);
			return crypto.createHash("md5").update(content).digest("hex");
		} catch {
			return null;
		}
	}

	function closeWatcher(absPath: string): void {
		const watcher = watchers.get(absPath);
		if (!watcher) return;
		try {
			watcher.close();
		} catch {
			// already closed
		}
		watchers.delete(absPath);
	}

	function schedule(fn: () => void, ms: number): void {
		if (shuttingDown) return;
		setTimeout(() => {
			if (shuttingDown) return;
			fn();
		}, ms);
	}

	function attachWatcher(absPath: string): void {
		if (shuttingDown) return;
		closeWatcher(absPath); // idempotent re-attach

		let watcher: fs.FSWatcher;
		try {
			watcher = fs.watch(absPath, (eventType) => {
				handleFsEvent(absPath, eventType);
			});
		} catch {
			// File doesn't exist yet (race with atomic rename). Retry once; if
			// still gone, give up silently. We never emit a deletion notice from
			// here, since we never confirmed the file was under active watch.
			schedule(() => {
				if (fs.existsSync(absPath)) attachWatcher(absPath);
			}, 50);
			return;
		}

		watcher.on("error", () => closeWatcher(absPath));
		watchers.set(absPath, watcher);
	}

	function handleFsEvent(absPath: string, eventType: string): void {
		if (suppressed.has(absPath)) return;

		// 'rename' on Linux typically means the file was replaced via atomic
		// save (vim, JetBrains, VS Code, etc.): the old inode is gone, so our
		// watcher is dead. Tear down and re-attach on the path.
		if (eventType === "rename") {
			closeWatcher(absPath);
			if (fs.existsSync(absPath)) {
				pending.set(absPath, "modified");
				attachWatcher(absPath);
			} else {
				// File may reappear shortly (atomic rename race). Retry once.
				schedule(() => {
					if (suppressed.has(absPath)) return;
					if (fs.existsSync(absPath)) {
						pending.set(absPath, "modified");
						attachWatcher(absPath);
					} else {
						pending.set(absPath, "deleted");
					}
				}, 50);
			}
			return;
		}

		pending.set(absPath, "modified");
	}

	function formatNotice(): string {
		const modified: string[] = [];
		const deleted: string[] = [];
		for (const [absPath, kind] of pending) {
			const rel = path.relative(cwd, absPath) || absPath;
			(kind === "deleted" ? deleted : modified).push(rel);
		}
		const parts: string[] = [];
		if (modified.length > 0) {
			parts.push(
				`Note: ${modified.length === 1 ? "this file was" : "these files were"} modified since the last turn: ${modified.join(", ")}.`,
			);
		}
		if (deleted.length > 0) {
			parts.push(
				`Note: ${deleted.length === 1 ? "this file was" : "these files were"} deleted since the last turn: ${deleted.join(", ")}.`,
			);
		}
		parts.push("Re-read before making further changes if the content is relevant.");
		return parts.join(" ");
	}

	function drainPending(): string | null {
		// Drop modified paths whose current content matches what the agent
		// last wrote (e.g. user undid their edit). Deletions can't be checked
		// this way and always pass through.
		for (const [absPath, kind] of Array.from(pending)) {
			if (kind !== "modified") continue;
			const expected = lastWrittenHash.get(absPath);
			if (!expected) continue;
			if (hashFile(absPath) === expected) pending.delete(absPath);
		}
		if (pending.size === 0) return null;
		const content = formatNotice();
		pending.clear();
		return content;
	}

	function clearAll(): void {
		for (const absPath of Array.from(watchers.keys())) closeWatcher(absPath);
		watched.clear();
		suppressed.clear();
		pending.clear();
		lastWrittenHash.clear();
	}

	// --- lifecycle ----------------------------------------------------------

	pi.on("session_start", async (_event, ctx) => {
		shuttingDown = false;
		cwd = ctx.cwd;
		clearAll();
	});

	pi.on("session_shutdown", async () => {
		shuttingDown = true;
		clearAll();
	});

	// --- agent-write suppression --------------------------------------------

	pi.on("tool_call", async (event) => {
		if (
			!isToolCallEventType("write", event) &&
			!isToolCallEventType("edit", event)
		) {
			return;
		}
		const absPath = resolvePath(event.input.path);
		suppressed.add(absPath);
		closeWatcher(absPath);
	});

	pi.on("tool_result", async (event) => {
		if (!isWriteToolResult(event) && !isEditToolResult(event)) return;
		const input = event.input as { path?: string };
		if (typeof input.path !== "string") return;
		const absPath = resolvePath(input.path);
		suppressed.delete(absPath);
		if (!event.isError) {
			watched.add(absPath);
			const hash = hashFile(absPath);
			if (hash !== null) lastWrittenHash.set(absPath, hash);
			attachWatcher(absPath);
		}
	});

	// Safety sweep: if a `tool_call` was blocked by another extension, its
	// matching `tool_result` never fires. Clear `suppressed`, and re-attach
	// only paths that were previously confirmed as watched.
	pi.on("turn_end", async () => {
		for (const absPath of Array.from(suppressed)) {
			suppressed.delete(absPath);
			if (watched.has(absPath) && fs.existsSync(absPath)) {
				attachWatcher(absPath);
			}
		}
	});

	// --- flush notices ------------------------------------------------------

	// Zero-lag flush for edits detected before the user submitted this prompt.
	pi.on("before_agent_start", async () => {
		const content = drainPending();
		if (!content) return;
		return {
			message: {
				customType: "edit-watcher",
				content,
				display: true,
			},
		};
	});

	// Mid-agent flush for edits detected between turns of the same prompt.
	// Default `sendMessage` delivery may lag by one turn, which is acceptable.
	pi.on("turn_start", async () => {
		const content = drainPending();
		if (!content) return;
		pi.sendMessage({
			customType: "edit-watcher",
			content,
			display: true,
		});
	});
}
