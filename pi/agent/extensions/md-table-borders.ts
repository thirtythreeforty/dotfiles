/**
 * Custom Markdown Table Style: borderless, dash-rule-under-header
 *
 * pi-tui's Markdown component hardcodes a full Unicode box-drawing grid
 * for table borders (┌─┬─┐ / │ / ├─┼─┤ / └─┴─┘), with no theme token or
 * config hook to change it (see pi-tui's markdown.js, renderTable()).
 * This monkey-patches Markdown.prototype.renderTable with a copy of that
 * algorithm, replacing the grid with a simple style: no side/top/bottom
 * borders, the whole table indented by INDENT, columns separated by GAP,
 * and a dash rule under the header row only (no separator between data
 * rows). E.g.:
 *
 *     Section Header   Section Header
 *     --------------   -----------------
 *     thing            thing
 *     thing            thing
 *
 * Implementation note (evil JS, same category as undo-last.ts):
 *   Markdown is a public export of @earendil-works/pi-tui, and pi's
 *   extension loader (jiti) aliases that package name to the exact same
 *   bundled module instance pi's own AssistantMessageComponent imports
 *   from (see loader.js VIRTUAL_MODULES / getAliases()). So patching
 *   Markdown.prototype here mutates the actual class pi uses to render
 *   every message, not a separate copy.
 *
 *   renderTable() is copied verbatim (minus the border-drawing lines)
 *   rather than wrapped-and-postprocessed, so column-width/wrapping math
 *   tracks this file, not pi-tui's. Expect to revisit on pi upgrades: if
 *   pi-tui's renderTable algorithm changes, this copy silently diverges
 *   instead of erroring. Diff against
 *   node_modules/@earendil-works/pi-tui/dist/components/markdown.js
 *   renderTable() after any pi update.
 *
 *   Unlike undo-last.ts, no globalThis capture is needed: Markdown is a
 *   stable bundled singleton (not recreated per session). The patch is
 *   applied unconditionally (no once-only guard) so that /reload picks up
 *   edits to this file: reload re-runs the factory below, which just
 *   reassigns Markdown.prototype.renderTable to a fresh closure over the
 *   current GAP/INDENT/RULE_CHAR. Direct assignment, not wrap-and-chain,
 *   so repeated reloads cannot stack extra layers of patching.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Markdown, visibleWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";

// Layout constants for the borderless style.
const INDENT = "  ";
const GAP = "    ";
const RULE_CHAR = "-";

type MarkdownProto = typeof Markdown.prototype & {
	renderInlineTokens(tokens: unknown[], styleContext: unknown): string;
	getLongestWordWidth(text: string, maxWidth: number): number;
	theme: { bold: (text: string) => string };
};

// Mirrors pi-tui's TableToken shape (marked's Tokens.Table).
interface TableCell {
	tokens?: unknown[];
}
interface TableToken {
	header: TableCell[];
	rows: TableCell[][];
	raw?: string;
}

export default function (pi: ExtensionAPI): void {
	const proto = Markdown.prototype as unknown as MarkdownProto;

	function wrapCellText(this: MarkdownProto, text: string, maxWidth: number): string[] {
		return wrapTextWithAnsi(text, Math.max(1, maxWidth));
	}

	function renderTable(
		this: MarkdownProto,
		token: TableToken,
		availableWidth: number,
		nextTokenType: string | undefined,
		styleContext: unknown,
	): string[] {
		const lines: string[] = [];
		const numCols = token.header.length;
		if (numCols === 0) {
			return lines;
		}

		// Reserve room for INDENT up front so wrapping accounts for it; it is
		// prefixed onto each emitted line below rather than factored into
		// per-column math.
		availableWidth -= INDENT.length;

		// No side borders in this style: overhead is just the gaps between columns.
		const borderOverhead = GAP.length * Math.max(0, numCols - 1);
		const availableForCells = availableWidth - borderOverhead;
		if (availableForCells < numCols) {
			// Too narrow to render a stable table. Fall back to raw markdown.
			const fallbackLines = token.raw ? wrapTextWithAnsi(token.raw, availableWidth) : [];
			if (nextTokenType && nextTokenType !== "space") {
				fallbackLines.push("");
			}
			return fallbackLines.map((line) => (line ? INDENT + line : line));
		}

		const maxUnbrokenWordWidth = 30;

		// Natural column widths: what each column needs without constraints.
		const naturalWidths: number[] = [];
		const minWordWidths: number[] = [];
		for (let i = 0; i < numCols; i++) {
			const headerText = this.renderInlineTokens(token.header[i].tokens ?? [], styleContext);
			naturalWidths[i] = visibleWidth(headerText);
			minWordWidths[i] = Math.max(1, this.getLongestWordWidth(headerText, maxUnbrokenWordWidth));
		}
		for (const row of token.rows) {
			for (let i = 0; i < row.length; i++) {
				const cellText = this.renderInlineTokens(row[i].tokens ?? [], styleContext);
				naturalWidths[i] = Math.max(naturalWidths[i] ?? 0, visibleWidth(cellText));
				minWordWidths[i] = Math.max(minWordWidths[i] ?? 1, this.getLongestWordWidth(cellText, maxUnbrokenWordWidth));
			}
		}

		let minColumnWidths = minWordWidths;
		let minCellsWidth = minColumnWidths.reduce((a, b) => a + b, 0);
		if (minCellsWidth > availableForCells) {
			minColumnWidths = new Array(numCols).fill(1);
			const remaining = availableForCells - numCols;
			if (remaining > 0) {
				const totalWeight = minWordWidths.reduce((total, width) => total + Math.max(0, width - 1), 0);
				const growth = minWordWidths.map((width) => {
					const weight = Math.max(0, width - 1);
					return totalWeight > 0 ? Math.floor((weight / totalWeight) * remaining) : 0;
				});
				for (let i = 0; i < numCols; i++) {
					minColumnWidths[i] += growth[i] ?? 0;
				}
				const allocated = growth.reduce((total, width) => total + width, 0);
				let leftover = remaining - allocated;
				for (let i = 0; leftover > 0 && i < numCols; i++) {
					minColumnWidths[i]++;
					leftover--;
				}
			}
			minCellsWidth = minColumnWidths.reduce((a, b) => a + b, 0);
		}

		// Column widths that fit within available width.
		const totalNaturalWidth = naturalWidths.reduce((a, b) => a + b, 0) + borderOverhead;
		let columnWidths: number[];
		if (totalNaturalWidth <= availableWidth) {
			// Everything fits naturally.
			columnWidths = naturalWidths.map((width, index) => Math.max(width, minColumnWidths[index]));
		} else {
			// Shrink columns to fit.
			const totalGrowPotential = naturalWidths.reduce((total, width, index) => {
				return total + Math.max(0, width - minColumnWidths[index]);
			}, 0);
			const extraWidth = Math.max(0, availableForCells - minCellsWidth);
			columnWidths = minColumnWidths.map((minWidth, index) => {
				const naturalWidth = naturalWidths[index];
				const minWidthDelta = Math.max(0, naturalWidth - minWidth);
				let grow = 0;
				if (totalGrowPotential > 0) {
					grow = Math.floor((minWidthDelta / totalGrowPotential) * extraWidth);
				}
				return minWidth + grow;
			});
			// Distribute rounding-error remainder.
			const allocated = columnWidths.reduce((a, b) => a + b, 0);
			let remaining = availableForCells - allocated;
			while (remaining > 0) {
				let grew = false;
				for (let i = 0; i < numCols && remaining > 0; i++) {
					if (columnWidths[i] < naturalWidths[i]) {
						columnWidths[i]++;
						remaining--;
						grew = true;
					}
				}
				if (!grew) {
					break;
				}
			}
		}

		// Header, with wrapping. No top border in this style.
		const headerCellLines = token.header.map((cell, i) => {
			const text = this.renderInlineTokens(cell.tokens ?? [], styleContext);
			return wrapCellText.call(this, text, columnWidths[i]);
		});
		const headerLineCount = Math.max(...headerCellLines.map((c) => c.length));
		for (let lineIdx = 0; lineIdx < headerLineCount; lineIdx++) {
			const rowParts = headerCellLines.map((cellLines, colIdx) => {
				const text = cellLines[lineIdx] ?? "";
				const padded = text + " ".repeat(Math.max(0, columnWidths[colIdx] - visibleWidth(text)));
				return this.theme.bold(padded);
			});
			lines.push(INDENT + rowParts.join(GAP));
		}

		// Dash rule under the header only; columns span full column width
		// (not just header width) so it still reads as a rule under wider data.
		const separatorLine = columnWidths.map((w) => RULE_CHAR.repeat(w)).join(GAP);
		lines.push(INDENT + separatorLine);

		// Rows, with wrapping. No separator between data rows in this style.
		for (let rowIndex = 0; rowIndex < token.rows.length; rowIndex++) {
			const row = token.rows[rowIndex];
			const rowCellLines = row.map((cell, i) => {
				const text = this.renderInlineTokens(cell.tokens ?? [], styleContext);
				return wrapCellText.call(this, text, columnWidths[i]);
			});
			const rowLineCount = Math.max(...rowCellLines.map((c) => c.length));
			for (let lineIdx = 0; lineIdx < rowLineCount; lineIdx++) {
				const rowParts = rowCellLines.map((cellLines, colIdx) => {
					const text = cellLines[lineIdx] ?? "";
					return text + " ".repeat(Math.max(0, columnWidths[colIdx] - visibleWidth(text)));
				});
				lines.push(INDENT + rowParts.join(GAP));
			}
		}

		// No bottom border in this style.
		if (nextTokenType && nextTokenType !== "space") {
			lines.push(""); // Spacing after table, matches surrounding block spacing.
		}
		return lines;
	}

	proto.renderTable = renderTable as unknown as MarkdownProto["renderTable"];
}
