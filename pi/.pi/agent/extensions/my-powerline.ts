// Personal status-line and editor-chrome adaptation of nicobailon/pi-powerline-footer (MIT).
// Only editor chrome and status display change; no editing/keybinding changes.
import { basename } from "node:path";
import { CustomEditor, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth, type TuiMouseEvent } from "@earendil-works/pi-tui";

const WIDGET = "my-powerline-status"; // Remove the previous version’s widget on reload.
const RESET = "\x1b[0m";
// Restore the original Nerd Font icons; allow a plain fallback if needed.
const icon = process.env.POWERLINE_NERD_FONTS === "0"
  ? { pi: "π", model: "", folder: "▱", branch: "⎇", context: "◫", sep: "❯" }
  : { pi: "\uE22C", model: "\uEC19", folder: "\uF115", branch: "\uF126", context: "\uF1C0", sep: "\uE0B1" };

function compact(n: number): string {
  if (n < 1000) return `${n}`;
  if (n < 10000) return `${(n / 1000).toFixed(1)}k`;
  if (n < 1_000_000) return `${Math.round(n / 1000)}k`;
  return `${(n / 1_000_000).toFixed(1)}M`;
}

function color(hex: string, text: string): string {
  const [r, g, b] = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16));
  return `\x1b[38;2;${r};${g};${b}m${text}${RESET}`;
}

function rainbow(text: string): string {
  const palette = ["#b281d6", "#d787af", "#febc38", "#e4c00f", "#89d281", "#00afaf", "#178fb9"];
  return [...text].map((char, i) => color(palette[i % palette.length]!, char)).join("");
}

export default function (pi: ExtensionAPI) {
  let active: ExtensionContext | undefined;
  let branch = "";
  let redraw: (() => void) | undefined;

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    active = ctx;

    // The status line is rendered in the editor's top border below.
    // Hide Pi's separate native footer to avoid a second status line.
    ctx.ui.setFooter((tui, _theme, footerData) => {
      branch = footerData.getGitBranch() ?? "";
      const unsub = footerData.onBranchChange(() => {
        branch = footerData.getGitBranch() ?? "";
        tui.requestRender();
      });
      return { render: (_width: number) => [], invalidate() {}, dispose: unsub };
    });

    ctx.ui.setWidget(WIDGET, undefined);
    ctx.ui.setEditorComponent((tui, theme, kb) => {
      redraw = () => tui.requestRender();
      return new class extends CustomEditor {
        private bottomLine = "";
        private visibleInputRows = 1;

        protected override renderTopBorder(width: number, hiddenLineCount: number): string {
          if (!active || width < 12) return color("#215477", "─".repeat(width));
          const contentWidth = width;
          const parts: string[] = [];
          const add = (part: string) => parts.push(part);
          add(color("#febc38", icon.pi));
          const model = active.model?.name ?? active.model?.id ?? "no-model";
          add(color("#d787af", `${icon.model ? icon.model + " " : ""}${model.replace(/^Claude /, "")}`));
          const level = pi.getThinkingLevel();
          const short = ({ minimal: "min", medium: "med", xhigh: "xhigh" } as Record<string, string>)[level] ?? level;
          add(level === "high" || level === "xhigh" || level === "max"
            ? rainbow(`thinking:${short}`) : color("#b281d6", `thinking:${short}`));
          add(color("#00afaf", `${icon.folder} ${basename(active.cwd) || active.cwd}`));
          if (branch) add(color("#febc38", `${icon.branch} ${branch}`));
          const usage = active.getContextUsage();
          const window = usage?.contextWindow ?? active.model?.contextWindow;
          if (window) {
            const percent = usage?.percent;
            const tint = percent !== null && percent !== undefined && percent > 90 ? "#e06060"
              : percent !== null && percent !== undefined && percent > 70 ? "#febc38" : "#999999";
            const used = usage?.tokens == null ? "?" : compact(usage.tokens);
            add(color(tint, `${icon.context} ${used}/${compact(window)}`));
          }
          const separator = color("#808080", ` ${icon.sep} `);
          const join = () => parts.filter(Boolean).join(separator);
          // Drop optional segments first; always preserve the context segment.
          for (const index of [3, 1, 2, 0]) {
            if (visibleWidth(join()) + 1 <= contentWidth) break;
            if (parts.length > index + 1) parts[index] = "";
          }
          const line = ` ${join()}`;
          const scroll = hiddenLineCount ? color("#808080", ` ↑${hiddenLineCount}`) : "";
          const text = truncateToWidth(line + scroll, contentWidth, "…");
          const tail = "─".repeat(Math.max(0, contentWidth - visibleWidth(text)));
          return text + color("#215477", tail);
        }

        protected override renderBottomBorder(width: number, hiddenLineCount: number): string {
          const label = hiddenLineCount ? ` ↓ ${hiddenLineCount} more ` : "";
          this.bottomLine = color("#215477", "─".repeat(Math.max(0, width - label.length)) + label);
          return this.bottomLine;
        }

        override render(width: number): string[] {
          if (width < 4) return super.render(width);
          // The base editor still owns text wrapping, cursor, history and autocomplete.
          const lines = super.render(width - 2);
          const bottom = lines.indexOf(this.bottomLine, 1);
          if (bottom < 0) return lines;
          this.visibleInputRows = bottom - 1;
          const edge = (s: string) => color("#215477", s);
          return lines.flatMap((line, i) => {
            if (i === 0) return [edge("╭") + line + edge("╮")];
            if (i < bottom) {
              const lastInputLine = i === bottom - 1;
              return [edge(lastInputLine ? "╰" : "│") + line + edge(lastInputLine ? "╯" : "│")];
            }
            if (i === bottom) return []; // No separate bottom-border row.
            // The autocomplete menu is outside the input box, but aligned with its text.
            return [" " + line + " "];
          });
        }

        override handleMouse(event: TuiMouseEvent) {
          // Base Editor accounts for a bottom-border row; our render omits it.
          const autocompleteStart = this.visibleInputRows + 1;
          return super.handleMouse({
            ...event, x: event.x - 1, width: Math.max(1, event.width - 2),
            y: event.y >= autocompleteStart ? event.y + 1 : event.y,
          });
        }
      }(tui, theme, kb);
    });
  });

  pi.on("message_update", () => redraw?.());
  pi.on("turn_end", () => redraw?.());
  pi.on("model_select", () => redraw?.());
}
