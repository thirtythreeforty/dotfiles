/**
 * Undo Last Message
 *
 * Rolls the active branch back to just before the most recent user message and
 * restores that user's prompt text into the editor. Equivalent to opening
 * `/tree`, navigating to the point before the last user message, then
 * repopulating the editor with the message that was sent.
 *
 * Shortcut: Alt+Shift+Up
 * Command:  /undo-last
 *
 * Implementation note (evil JS):
 *   `navigateTree` is only exposed on ExtensionCommandContext, which is
 *   only passed to command handlers. Shortcut handlers receive the plain
 *   ExtensionContext, and pi does not expose a public API to invoke an
 *   extension command from a shortcut. We work around that by monkey-
 *   patching `ExtensionRunner.prototype.bindCommandContext` to stash the
 *   TUI-integrated command actions object that pi passes in on every
 *   session bind (initial load and /reload). From the shortcut we then
 *   call `capturedActions.navigateTree(...)` directly, which triggers the
 *   same chat re-render and editor repopulation the slash command does.
 *
 *   The capture is stored on `globalThis[Symbol.for(...)]` rather than a
 *   module-local variable so it survives jiti re-evaluating this module on
 *   /reload: the wrapper installed on the prototype on the original load
 *   would otherwise write to a module-scope variable the re-evaluated
 *   module can no longer see.
 *
 *   This depends on the shape of the object pi passes to bindCommandContext.
 *   Expect to revisit on pi upgrades. The long-term fix is upstream:
 *   either expose `navigateTree` on ExtensionContext for shortcuts, or add
 *   a public `ctx.invokeCommand(name, args)` that runs a registered
 *   extension command with a proper command context.
 */

import type {
	ExtensionAPI,
	ExtensionCommandContext,
	ExtensionCommandContextActions,
	ExtensionContext,
	SessionEntry,
} from "@mariozechner/pi-coding-agent";
import { ExtensionRunner } from "@mariozechner/pi-coding-agent";

type NavigateTree = ExtensionCommandContext["navigateTree"];

const PATCHED = Symbol.for("undo-last:bindCommandContext-patched");
const CAPTURED_KEY = Symbol.for("undo-last:captured-command-actions");

type RunnerProto = {
	bindCommandContext: (actions: ExtensionCommandContextActions | undefined) => void;
	[key: symbol]: unknown;
};

type GlobalWithCapture = typeof globalThis & {
	[CAPTURED_KEY]?: ExtensionCommandContextActions;
};

// Install the prototype patch at most once per process. On /reload jiti
// re-evaluates this module, but the prototype lives in Node's ESM cache
// and still carries the wrapper + PATCHED marker from the original load.
const proto = ExtensionRunner.prototype as unknown as RunnerProto;
if (!proto[PATCHED]) {
	const originalBindCommandContext = proto.bindCommandContext;
	proto.bindCommandContext = function (
		actions: ExtensionCommandContextActions | undefined,
	): void {
		if (actions) {
			(globalThis as GlobalWithCapture)[CAPTURED_KEY] = actions;
		}
		return originalBindCommandContext.call(this, actions);
	};
	proto[PATCHED] = true;
}

function getCapturedActions(): ExtensionCommandContextActions | undefined {
	return (globalThis as GlobalWithCapture)[CAPTURED_KEY];
}

function findLastUserEntryId(branch: SessionEntry[]): string | undefined {
	for (let i = branch.length - 1; i >= 0; i--) {
		const entry = branch[i];
		if (entry.type === "message" && entry.message.role === "user") {
			return entry.id;
		}
	}
	return undefined;
}

export default function (pi: ExtensionAPI): void {
	async function performUndo(
		navigateTree: NavigateTree,
		ctx: ExtensionContext,
	): Promise<void> {
		if (!ctx.isIdle()) {
			ctx.abort();
		}

		const lastUserId = findLastUserEntryId(ctx.sessionManager.getBranch());
		if (!lastUserId) {
			ctx.ui.notify("No user message to undo", "warning");
			return;
		}

		// navigateTree on the TUI-integrated wrapper handles:
		//   - moving leaf to parent (resetLeaf if root)
		//   - returning editorText for user-message targets
		//   - chatContainer.clear() + renderInitialMessages() in interactive mode
		//   - editor.setText(result.editorText) when the editor is empty
		const result = await navigateTree(lastUserId);
		if (result.cancelled) {
			ctx.ui.notify("Undo cancelled", "info");
			return;
		}
		ctx.ui.notify("Rolled back to before last user message", "info");
	}

	pi.registerCommand("undo-last", {
		description:
			"Roll back to just before the last user message and restore its text to the editor",
		handler: async (_args: string, ctx: ExtensionCommandContext) => {
			await performUndo(ctx.navigateTree, ctx);
		},
	});

	pi.registerShortcut("alt+shift+up", {
		description:
			"Undo last message (roll back to before the last user message)",
		handler: async (ctx: ExtensionContext) => {
			const actions = getCapturedActions();
			if (!actions) {
				ctx.ui.notify(
					"Undo unavailable: command actions not bound yet. Try /undo-last once, then use the shortcut.",
					"error",
				);
				return;
			}
			await performUndo(actions.navigateTree, ctx);
		},
	});
}
