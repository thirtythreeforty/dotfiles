/**
 * Model Cost Extension – shows cost-per-megatoken for the currently selected model
 *
 * Displays cost in the footer status area using the same arrow format as
 * the built-in token counter (↑$3.00 ↓$15.00) styled with the footer's dim colour.
 * Also provides a /model-cost command for a detailed breakdown.
 *
 * Cost data comes from the model descriptor's `cost` field, defined either:
 *  - Built into pi for well-known models (Anthropic, OpenAI, Google, etc.)
 *  - Configured by the user in ~/.pi/agent/models.json
 * The values are dollars per million tokens (e.g. { input: 3, output: 15 }).
 */

import type { ExtensionAPI, ModelDescriptor } from "@mariozechner/pi-coding-agent";

/** Format a per-million-token cost with compact arrow notation */
function formatCost(model?: ModelDescriptor | null, dim?: (s: string) => string): string | undefined {
	if (!model?.cost) return undefined;
	const { input, output, cacheRead, cacheWrite } = model.cost;

	// Free / local model: show nothing
	if (input === 0 && output === 0 && cacheRead === 0 && cacheWrite === 0) {
		return undefined;
	}

	const fmt = (n: number) => `$${n.toFixed(2)}`;
	let text = `↑${fmt(input)} ↓${fmt(output)}`;
	if (cacheRead > 0) text += ` ⤓${fmt(cacheRead)}`;
	return dim ? dim(text) : text;
}

export default function modelCostExtension(pi: ExtensionAPI) {
	/** Update the footer status for the given model */
	function updateStatus(model: ModelDescriptor | null | undefined, ctx: { hasUI: boolean; ui: { setStatus: (key: string, text: string | undefined) => void; theme: { fg: (color: string, text: string) => string } } }) {
		if (!ctx.hasUI) return;
		const status = formatCost(model, (s) => ctx.ui.theme.fg("dim", s));
		ctx.ui.setStatus("model-cost", status);
	}

	// Show cost on session start / resume
	pi.on("session_start", async (_event, ctx) => {
		updateStatus(ctx.model, ctx);
	});

	// When the model changes via /model, Ctrl+P, or session restore
	pi.on("model_select", async (event, ctx) => {
		updateStatus(event.model, ctx);
	});

	// Clean up on exit or session replacement
	pi.on("session_shutdown", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		ctx.ui.setStatus("model-cost", undefined);
	});

	// Command: detailed breakdown (useful for seeing provider/cache info)
	pi.registerCommand("model-cost", {
		description: "Show per-megatoken pricing for the current model",
		handler: async (_args, ctx) => {
			const m = ctx.model;
			if (!m?.cost) {
				ctx.ui.notify("No cost data available.", "info");
				return;
			}
			const { input, output, cacheRead, cacheWrite } = m.cost;
			const fmt = (n: number) => (n === 0 ? "free" : `$${n.toFixed(2)} / Mtok`);

			const lines = [
				`Model   : ${m.provider}/${m.id}`,
				`Input   : ${fmt(input)}`,
				`Output  : ${fmt(output)}`,
			];
			if (cacheRead > 0 || cacheWrite > 0) {
				lines.push(`Cache read : ${fmt(cacheRead)}`);
				lines.push(`Cache write: ${fmt(cacheWrite)}`);
			}
			ctx.ui.notify(lines.join("\n"), "info");
		},
	});
}