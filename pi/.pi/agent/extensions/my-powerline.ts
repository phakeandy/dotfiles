// Personal status-line and editor-chrome adaptation of nicobailon/pi-powerline-footer (MIT).
// Only editor chrome, status display and fullscreen scroll steps change.
import { basename } from "node:path";
import { CustomEditor, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
  isKeyRelease,
  matchesKey,
  truncateToWidth,
  visibleWidth,
  type TuiMouseEvent,
} from "@earendil-works/pi-tui";

const WIDGET = "my-powerline-status"; // Remove the previous version’s widget on reload.
const RESET = "\x1b[0m";
// Restore the original Nerd Font icons; allow a plain fallback if needed.
const icon = process.env.POWERLINE_NERD_FONTS === "0"
  ? { pi: "π", model: "", folder: "▱", branch: "⎇", context: "◫", speed: "~", sep: "❯" }
  : { pi: "\uE22C", model: "\uEC19", folder: "\uF115", branch: "\uF126", context: "\uF1C0", speed: "\uF0E7", sep: "\uE0B1" };
// Fullscreen transcript hint. The stock one is a selected-bg pill reading
// "↓ Jump to latest message · Ctrl+End" pinned to the last transcript row;
// a single dim glyph (or nothing) is enough once scrolling hides the composer.
const SCROLL_HINT = process.env.POWERLINE_SCROLL_HINT ?? "off"; // off | glyph | full
const HIDE_EDITOR_ON_SCROLL = process.env.POWERLINE_HIDE_EDITOR !== "0";
// Fullscreen: shift+up/down walk the transcript this many lines per press
// (ctrl+up/down jump to the ends, bound in keybindings.json).
const SCROLL_LINES = 2;
// Output-speed readout (see speedReading). Segments give way in this order on a
// narrow terminal; the context segment is never dropped.
const SPEED = process.env.POWERLINE_SPEED !== "0";
const TRIM_ORDER = ["folder", "branch", "speed", "model", "thinking", "session"] as const;

// Fullscreen renderer surface we touch. The getters are public on TuiAltScreen,
// and the object handed to the editor/footer factories is a proxy over the live
// renderer, so this stays valid across fullscreen <-> regular switches.
type ScrollViewLike = {
  scrollTop: number;
  viewportHeight: number;
  contentHeight?: number;
  isFollowingEnd?: boolean;
};

type AltScreenChrome = {
  scrollToEndIndicator?: (() => string) | undefined;
  // Private on TuiAltScreen, but the dock hands us the live instance.
  getPrimaryScrollView?: () => ScrollViewLike | undefined;
  scrollBy?: (lines: number) => void;
};

function isAltScreen(tui: unknown): boolean {
  return "scrollToEndIndicator" in (tui as AltScreenChrome);
}

const HINT_GLYPH = () => color("#6c6c6c", " ↓ ");

function patchScrollHint(tui: unknown): void {
  const alt = tui as AltScreenChrome;
  if (SCROLL_HINT === "full" || !isAltScreen(tui)) return; // Regular mode has no pill.
  alt.scrollToEndIndicator = SCROLL_HINT === "glyph" ? HINT_GLYPH : undefined;
}

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

/**
 * Output speed is a whole-response average: the clock starts when the request
 * goes out and stops when the response ends.
 *
 * Decode-only timing was tried first and does not survive contact with real
 * providers. KeyLights (anthropic-messages) delivers a 700-token Chinese reply
 * as ~200 deltas inside 13-16ms while the response actually takes 7-9s, so a
 * first-delta-to-last-delta clock reported either nothing or ~19000 tok/s. The
 * provider's own `durationMs` is the only honest denominator, and averaging
 * over it keeps one meaning instead of switching clock per provider.
 *
 * Below these bounds a reading describes the sample, not the model: a 15-token
 * reply that took 80ms would report several hundred tok/s.
 */
export const SPEED_MIN_TOKENS = 20;
export const SPEED_MIN_MS = 400;

/**
 * Token estimate for streamed text, used until the provider reports real usage
 * (Anthropic does mid-stream, OpenAI-compatible endpoints only on the last
 * chunk). Latin text runs ~4 chars/token; CJK and other full-width glyphs are
 * about one token each, so counting them as 4 characters undercounts ~4x.
 */
export function estimateTokens(text: string): number {
  let narrow = 0;
  let wide = 0;
  for (const char of text) {
    if (isWideCodePoint(char.codePointAt(0) ?? 0)) wide += 1;
    else narrow += 1;
  }
  return narrow / 4 + wide;
}

function isWideCodePoint(cp: number): boolean {
  return (
    (cp >= 0x1100 && cp <= 0x115f) || // Hangul Jamo
    (cp >= 0x2600 && cp <= 0x27bf) || // Dingbats/emoji-ish symbols that render full width
    (cp >= 0x2e80 && cp <= 0x303e) || // CJK radicals, Kangxi, CJK punctuation
    (cp >= 0x3041 && cp <= 0x33ff) || // Kana, CJK compatibility
    (cp >= 0x3400 && cp <= 0x4dbf) ||
    (cp >= 0x4e00 && cp <= 0x9fff) ||
    (cp >= 0xa000 && cp <= 0xa4cf) || // Yi
    (cp >= 0xac00 && cp <= 0xd7a3) || // Hangul syllables
    (cp >= 0xf900 && cp <= 0xfaff) ||
    (cp >= 0xfe30 && cp <= 0xfe6f) ||
    (cp >= 0xff00 && cp <= 0xff60) || // Full-width forms
    (cp >= 0xffe0 && cp <= 0xffe6) ||
    (cp >= 0x1f000 && cp <= 0x1faff) || // Emoji
    (cp >= 0x20000 && cp <= 0x3fffd)
  );
}

export function formatSpeed(tokensPerSecond: number): string {
  return `${tokensPerSecond.toFixed(1)} tok/s`;
}

/**
 * One response's speed sample, timed from the request leaving to the response
 * ending. `estimate` accumulates streamed text and `actual` is the
 * provider-reported output count (0 while unknown); a reading takes whichever
 * is larger until the response ends, where `actual` wins.
 */
export type SpeedTracker =
  | { phase: "idle"; startedAt: number }
  | { phase: "streaming" | "done"; startedAt: number; at: number; estimate: number; actual: number };

export type SpeedReading = { tps: number; streaming: boolean };

/** Arm a new response at `startedAt`. The previous reading stays on screen until output resumes. */
export function speedBegin(startedAt: number): SpeedTracker {
  return { phase: "idle", startedAt };
}

export function speedDelta(
  tracker: SpeedTracker,
  delta: string,
  at: number,
  actual: number,
): SpeedTracker {
  const prior = tracker.phase === "idle" ? undefined : tracker;
  return {
    phase: "streaming",
    startedAt: tracker.startedAt,
    at,
    estimate: (prior?.estimate ?? 0) + estimateTokens(delta),
    actual: Math.max(prior?.actual ?? 0, actual),
  };
}

export function speedEnd(tracker: SpeedTracker, at: number, actual: number): SpeedTracker {
  // No delta ever arrived: there is no sample, and any tokens the provider
  // reports for an empty response describe nothing worth a rate.
  if (tracker.phase === "idle") return tracker;
  return {
    phase: "done",
    startedAt: tracker.startedAt,
    at,
    estimate: tracker.estimate,
    // A completed response's provider count is authoritative; keep the estimate
    // only when the provider reported nothing at all.
    actual: actual > 0 ? actual : tracker.actual,
  };
}

/** Reading for the status line, or undefined when the sample cannot support one. */
export function speedReading(tracker: SpeedTracker): SpeedReading | undefined {
  if (tracker.phase === "idle") return undefined;
  const tokens = tracker.phase === "done" && tracker.actual > 0
    ? tracker.actual
    : Math.max(tracker.estimate, tracker.actual);
  const elapsed = tracker.at - tracker.startedAt;
  if (tokens <= 0 || elapsed <= 0) return undefined;
  if (tokens < SPEED_MIN_TOKENS || elapsed < SPEED_MIN_MS) return undefined;
  return { tps: (tokens * 1000) / elapsed, streaming: tracker.phase === "streaming" };
}

export type ComposerVisibilityState = {
  hidden: boolean;
  lastViewportTop: number;
};

/**
 * The dock's minimum height for the editor: zero while collapsed, otherwise
 * never more rows than the editor actually paints. pi hard-codes `minSize: 3`
 * (`chat-viewport.js`), but this editor folds the bottom border into the last
 * input row, so a one-line composer renders two rows — the unclamped minimum
 * leaves a blank row below it.
 */
export function composerMinSize(
  hidden: boolean,
  renderedRows: number,
  original: number | undefined,
): number {
  if (hidden) return 0;
  return Math.min(original ?? 0, renderedRows);
}

/**
 * Decide whether the collapsed composer hides itself on this frame.
 *
 * Hiding now really returns the rows to the transcript instead of rendering
 * blank ones; the catch is that the transcript viewport grows. Once it is tall
 * enough to fit everything, pi clamps the scroll position back to the end and
 * flips `isFollowingOutput` back on, so the composer pops back and the scroll
 * position is lost — the reason the old version could only blank the rows.
 *
 * So collapse only when more than `composerRows` lines sit below the viewport:
 * after growing, the view still ends before the transcript end and the state is
 * stable. Collapsing also only triggers on an upward scroll, so typing does not
 * bring the composer back just to have it vanish on the next frame.
 */
export function stepComposerVisibility(
  state: ComposerVisibilityState,
  view: ScrollViewLike,
  composerRows: number,
): ComposerVisibilityState & { hide: boolean } {
  const below =
    typeof view.contentHeight === "number"
      ? view.contentHeight - view.viewportHeight - view.scrollTop
      : undefined;

  if (state.hidden) {
    // Back at the live end (Ctrl+End, scrolling down, or new output catching up).
    if (view.isFollowingEnd === true || below === undefined || below <= 0) {
      return { hidden: false, lastViewportTop: view.scrollTop, hide: false };
    }
    return { ...state, hide: true };
  }

  const hide =
    state.lastViewportTop >= 0 &&
    view.scrollTop < state.lastViewportTop &&
    below !== undefined &&
    below > composerRows;
  return { hidden: hide, lastViewportTop: view.scrollTop, hide };
}

/**
 * pi's fullscreen dock hard-codes `minSize: 3` for the editor
 * (`chat-viewport.js`), so returning zero lines only paints the rows blank —
 * they are still reserved. Reclaiming them means clearing that layout entry's
 * minSize too; `Stack.entries` is read by both VStack.render and the layout
 * tree, so one mutation covers both.
 */
export type StackEntryLike = { component: unknown; minSize?: number };
export type StackLike = { entries?: StackEntryLike[] };
export type LayoutBoxLike = { component?: StackLike; children?: LayoutBoxLike[] };
export type LayoutFrameLike = { root?: LayoutBoxLike };

/** Whether `component` is `editor` or wraps it (pi puts the editor in a Container). */
export function wrapsEditor(component: unknown, editor: unknown, depth = 0): boolean {
  if (component === editor) return true;
  if (depth > 8) return false;
  const children = (component as { children?: unknown[] } | undefined)?.children;
  return Array.isArray(children) && children.some((child) => wrapsEditor(child, editor, depth + 1));
}

/**
 * The innermost stack entry that wraps `editor` — that is the fullscreen dock's
 * editor slot, whose `minSize: 3` is what keeps the rows reserved. The editor
 * itself never shows up in the layout tree (the dock renders it inside a plain
 * Container), so the match has to go through `children`.
 */
export function findDockEntry(
  root: LayoutBoxLike | undefined,
  editor: unknown,
): { stack: StackLike; entry: StackEntryLike } | undefined {
  const search = (box: LayoutBoxLike): { stack: StackLike; entry: StackEntryLike } | undefined => {
    // Deeper wins: the root stack also wraps the editor through the dock.
    for (const child of box.children ?? []) {
      const deeper = search(child);
      if (deeper) return deeper;
    }
    const stack = box.component;
    if (!stack?.entries) return undefined;
    const entry = stack.entries.find((candidate) => wrapsEditor(candidate.component, editor));
    return entry ? { stack, entry } : undefined;
  };
  return root ? search(root) : undefined;
}

export default function (pi: ExtensionAPI) {
  let active: ExtensionContext | undefined;
  let branch = "";
  let sessionTag = "";
  let redraw: (() => void) | undefined;
  // The reading is kept across messages: `message_start` only arms the reset so
  // the last number stays on screen instead of blinking out during prefill.
  let speed: SpeedTracker = speedBegin(0);
  let awaitingFirstDelta = false;
  let requestedAt = 0;

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    active = ctx;
    // Session ids are UUIDv7: the first 6 hex chars are the top 24 bits of the
    // millisecond timestamp, so every session started within the same ~4.7h
    // window shares that prefix. The trailing chars are pure randomness, and 8
    // hex chars is the shortest token tmux-fingers will pick up.
    sessionTag = ctx.sessionManager.getSessionId().slice(-8) || icon.pi;

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
          const parts: { key: (typeof TRIM_ORDER)[number]; text: string }[] = [];
          const add = (key: (typeof TRIM_ORDER)[number], text: string) => parts.push({ key, text });
          add("session", color("#febc38", sessionTag || icon.pi));
          const model = active.model?.name ?? active.model?.id ?? "no-model";
          add("model", color("#d787af", `${icon.model ? icon.model + " " : ""}${model.replace(/^Claude /, "")}`));
          const level = pi.getThinkingLevel();
          const short = ({ minimal: "min", medium: "med", xhigh: "xhigh" } as Record<string, string>)[level] ?? level;
          add("thinking", level === "high" || level === "xhigh" || level === "max"
            ? rainbow(`thinking:${short}`) : color("#b281d6", `thinking:${short}`));
          add("folder", color("#00afaf", `${icon.folder} ${basename(active.cwd) || active.cwd}`));
          if (branch) add("branch", color("#febc38", `${icon.branch} ${branch}`));
          const usage = active.getContextUsage();
          const window = usage?.contextWindow ?? active.model?.contextWindow;
          if (window) {
            const percent = usage?.percent;
            const tint = percent !== null && percent !== undefined && percent > 90 ? "#e06060"
              : percent !== null && percent !== undefined && percent > 70 ? "#febc38" : "#999999";
            const used = usage?.tokens == null ? "?" : compact(usage.tokens);
            add("context", color(tint, `${icon.context} ${used}/${compact(window)}`));
          }
          if (SPEED) {
            const reading = speedReading(speed);
            if (reading) {
              const tint = reading.streaming ? "#999999" : "#6c6c6c";
              add("speed", color(tint, `${icon.speed} ${formatSpeed(reading.tps)}`));
            }
          }
          const separator = color("#808080", ` ${icon.sep} `);
          const join = () => parts.map((part) => part.text).filter(Boolean).join(separator);
          // Drop optional segments in TRIM_ORDER until the line fits; the
          // context segment is not in that list, so it always survives.
          for (const key of TRIM_ORDER) {
            if (visibleWidth(join()) + 1 <= contentWidth) break;
            const segment = parts.find((part) => part.key === key);
            if (segment) segment.text = "";
          }
          const line = ` ${join()}`;
          const scroll = hiddenLineCount ? color("#808080", ` ↑${hiddenLineCount}`) : "";
          const text = truncateToWidth(line + scroll, contentWidth, "…");
          const tail = "─".repeat(Math.max(0, contentWidth - visibleWidth(text)));
          return text + color("#215477", tail);
        }

        // Fullscreen only: while the transcript is scrolled away from the live
        // end, give the composer's rows back to the transcript and bring them
        // back on the next keystroke.
        private composer: ComposerVisibilityState = { hidden: false, lastViewportTop: -1 };

        private showComposer(): void {
          if (!this.composer.hidden) return;
          const view = (tui as AltScreenChrome).getPrimaryScrollView?.();
          this.composer = { hidden: false, lastViewportTop: view?.scrollTop ?? this.composer.lastViewportTop };
        }

        private scrollView(): ScrollViewLike | undefined {
          if (!HIDE_EDITOR_ON_SCROLL || !isAltScreen(tui)) return undefined;
          return (tui as AltScreenChrome).getPrimaryScrollView?.();
        }

        private dockEntry: StackEntryLike | undefined;
        private dockStack: StackLike | undefined;
        private dockOriginalMinSize: number | undefined;

        /**
         * Keep the dock's minimum height for the editor in sync with what the
         * editor actually renders (and drop it to zero while collapsed).
         * Returns whether the dock was found: without it the rows would only go
         * blank, so the caller keeps the composer.
         */
        private applyDockMinSize(hidden: boolean, renderedRows: number): boolean {
          if (!this.dockEntry || !this.dockStack?.entries?.includes(this.dockEntry)) {
            const layout = (tui as unknown as { currentLayout?: LayoutFrameLike }).currentLayout;
            const found = findDockEntry(layout?.root, this);
            this.dockStack = found?.stack;
            this.dockEntry = found?.entry;
            // Capture the baseline once: re-discovery may already see our value.
            if (found && this.dockOriginalMinSize === undefined) {
              this.dockOriginalMinSize = found.entry.minSize;
            }
          }
          if (!this.dockEntry) return false;
          this.dockEntry.minSize = composerMinSize(hidden, renderedRows, this.dockOriginalMinSize);
          return true;
        }

        private renderComposer(width: number): string[] {
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

        override render(width: number): string[] {
          const lines = this.renderComposer(width);
          const view = this.scrollView();
          if (view) this.composer = stepComposerVisibility(this.composer, view, lines.length);
          else this.composer.hidden = false;

          // Without the dock, collapsing would only paint the rows blank.
          if (this.composer.hidden && !this.applyDockMinSize(true, 0)) this.composer.hidden = false;
          if (!this.composer.hidden) this.applyDockMinSize(false, lines.length);
          patchScrollHint(tui);
          // No placeholder rows: the transcript grows by exactly these rows, so
          // scrolling up buys readable lines instead of blank space.
          return this.composer.hidden ? [] : lines;
        }

        override handleInput(data: string): void {
          // Scroll keys must not resurrect the collapsed composer: scrolling up
          // would only hide it again, and scrolling down should keep it hidden
          // until the live end is reached.
          if (this.scrollViewByKey(data)) return;
          this.showComposer(); // Any other keystroke brings the composer back.
          super.handleInput(data);
        }

        /**
         * Fullscreen only: shift+up/down step the transcript a few lines at a
         * time. They are deliberately unbound in keybindings.json so the key
         * reaches the editor; the alt-screen actions can only move one line.
         */
        private scrollViewByKey(data: string): boolean {
          const alt = tui as AltScreenChrome;
          if (!isAltScreen(tui) || !alt.scrollBy || isKeyRelease(data)) return false;
          if (matchesKey(data, "shift+up")) {
            alt.scrollBy(-SCROLL_LINES);
            return true;
          }
          if (matchesKey(data, "shift+down")) {
            alt.scrollBy(SCROLL_LINES);
            return true;
          }
          return false;
        }

        override insertTextAtCursor(text: string): void {
          this.showComposer(); // Programmatic insert (clipboard image, paste).
          super.insertTextAtCursor(text);
        }

        protected override renderBottomBorder(width: number, hiddenLineCount: number): string {
          const label = hiddenLineCount ? ` ↓ ${hiddenLineCount} more ` : "";
          this.bottomLine = color("#215477", "─".repeat(Math.max(0, width - label.length)) + label);
          return this.bottomLine;
        }

        override handleMouse(event: TuiMouseEvent) {
          // While the composer is blanked out, stay out of the way: wheel events over
          // these rows must keep scrolling the transcript, and a click has nothing to
          // hit.
          if (this.composer.hidden) return undefined;
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

  pi.on("message_start", (event) => {
    if (event.message.role !== "assistant") return;
    // Average over the whole response: `timestamp` is when the request went
    // out, which is also where the provider's own `durationMs` starts. The
    // reading stays on screen until output resumes.
    requestedAt = event.message.timestamp ?? Date.now();
    awaitingFirstDelta = true;
  });

  if (SPEED) {
    pi.on("message_update", (event) => {
      const update = event.assistantMessageEvent;
      const delta =
        update.type === "text_delta" || update.type === "thinking_delta" || update.type === "toolcall_delta"
          ? update.delta
          : undefined;
      if (delta === undefined) return;
      if (awaitingFirstDelta) {
        speed = speedBegin(requestedAt);
        awaitingFirstDelta = false;
      }
      // `usage.output` reaches us mid-stream on Anthropic and only on the last
      // chunk elsewhere; speedReading prefers it as soon as it exceeds the estimate.
      speed = speedDelta(speed, delta, Date.now(), event.message.usage?.output ?? 0);
      redraw?.();
    });

    pi.on("message_end", (event) => {
      if (event.message.role !== "assistant") return;
      // Aborted before the first delta: there is no sample for this response, and
      // the tracker still holds the previous one — finalizing it with this
      // response's end time would stretch its elapsed time into a wrong number.
      if (awaitingFirstDelta) {
        awaitingFirstDelta = false;
        return;
      }
      speed = speedEnd(speed, Date.now(), event.message.usage?.output ?? 0);
      redraw?.();
    });
  }

  pi.on("message_update", () => redraw?.());
  pi.on("turn_end", () => redraw?.());
  pi.on("model_select", () => redraw?.());
  pi.on("thinking_level_select", () => redraw?.());
}
