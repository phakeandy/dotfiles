/**
 * quiet-tools — 把工具调用从"原始输出"改成"意图 + 判定"
 *
 * 折叠态（默认，不需要按任何键）：
 *   read  ~/docs/settings.md              → 107 lines
 *   bash  grep -n -i tuiMode docs/set…    → 8 lines
 *   grep  /tuiMode/ in docs               → 8 matches
 *
 * 展开态（ctrl+o）：完整原始输出，等同内置渲染器。
 *
 * 设计原则：结果用「计数/判定」而不是「截断的前 N 行」。
 * 截断的 grep 输出和完整 grep 输出一样没有可读性；计数才携带信息。
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	createBashTool,
	createEditTool,
	createFindTool,
	createGrepTool,
	createLsTool,
	createReadTool,
	createWriteTool,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { homedir } from "os";

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

function shorten(p: string): string {
	const home = homedir();
	if (p && p.startsWith(home)) return `~${p.slice(home.length)}`;
	return p || "";
}

/**
 * 路径也要限宽：node_modules/.pnpm/... 这种前缀会拖着整行换行，
 * 保留尾部有信息量的两三个路径段。
 */
function shortPath(p: string, max = 46): string {
	const s = shorten(p) || ".";
	if (s.length <= max) return s;
	const parts = s.split("/").filter(Boolean);
	let out = parts.slice(-2).join("/");
	for (let i = parts.length - 3; i >= 0; i--) {
		if (out.length + parts[i].length + 1 > max) break;
		out = `${parts[i]}/${out}`;
	}
	return `…/${out}`;
}

type Content = { type: string; text?: string };
type ToolResult = { content?: Content[] };

function resultText(result: ToolResult | undefined): string {
	const c = result?.content?.find((x) => x.type === "text");
	return c?.text ?? "";
}

function nonEmptyLines(s: string): string[] {
	const t = (s ?? "").trim();
	return t ? t.split("\n").filter((l) => l.trim().length > 0) : [];
}

function clip(s: string, max: number): string {
	const flat = (s ?? "").replace(/\s+/g, " ").trim();
	return flat.length > max ? `${flat.slice(0, max - 1)}…` : flat;
}

/**
 * 把 shell 命令压成一行可读的意图。
 * 最大的噪音源是 agent 习惯写的 `cd <超长路径> && <真正的命令>`，
 * 前缀贡献 90% 的视觉宽度、0% 的信息。
 */
function briefCommand(cmd: string, max = 110): string {
	let c = (cmd ?? "").replace(/\s+/g, " ").trim();
	for (let i = 0; i < 8; i++) {
		const m = c.match(/^cd\s+(?:"[^"]*"|'[^']*'|\S+)\s*(?:&&|;)\s*/);
		if (!m) break;
		c = c.slice(m[0].length).trim();
	}
	if (!c) c = (cmd ?? "").replace(/\s+/g, " ").trim();
	return clip(c, max);
}

// ---------------------------------------------------------------------------
// 通用覆盖：转发内置工具的全部字段，只替换 execute 与渲染
// ---------------------------------------------------------------------------

type Theme = any;
type Builtin = Record<string, unknown> & { execute: (...a: any[]) => any };

interface Renderers {
	call: (args: any, theme: Theme) => string;
	/** 返回 null 表示折叠态不显示任何东西。错误不经过这里，见 defineTool。 */
	result: (text: string, theme: Theme) => string | null;
}

function defineTool(create: (cwd: string) => Builtin, render: Renderers) {
	const cache = new Map<string, Builtin>();
	const get = (cwd: string): Builtin => {
		let t = cache.get(cwd);
		if (!t) {
			t = create(cwd);
			cache.set(cwd, t);
		}
		return t;
	};

	// 用 cwd 无关的实例取 name/description/parameters 等静态字段
	const proto = create(process.cwd());

	return {
		...proto,
		async execute(toolCallId: string, params: any, signal: any, onUpdate: any, ctx: any) {
			return get(ctx.cwd).execute(toolCallId, params, signal, onUpdate, ctx);
		},
		renderCall(args: any, theme: Theme) {
			return new Text(render.call(args ?? {}, theme), 0, 0);
		},
		renderResult(
			result: ToolResult,
			options: { expanded?: boolean },
			theme: Theme,
			context?: { isError?: boolean },
		) {
			const txt = resultText(result).trim();

			if (options?.expanded) {
				// 展开态交回内置视觉：完整输出
				return new Text(txt ? `\n${txt}` : "", 0, 0);
			}

			// 错误永远不折叠：静默失败比噪音更贵
			if (context?.isError) {
				const lines = nonEmptyLines(txt).slice(0, 6);
				return new Text(` ${theme.fg("error", lines.join("\n") || "error")}`, 0, 0);
			}

			const rendered = render.result(txt, theme);
			if (rendered === null) return new Text("", 0, 0);
			return new Text(` ${rendered}`, 0, 0);
		},
	};
}

// 各工具的折叠态判定
function countJudgement(
	txt: string,
	theme: Theme,
	forms: [singular: string, plural: string],
	zeroHint?: string,
): string {
	const lines = nonEmptyLines(txt);
	const first = lines[0] ?? "";
	if (lines.length === 0 || (zeroHint && first.startsWith(zeroHint))) {
		return theme.fg("dim", `→ 0 ${forms[1]}`);
	}
	const n = lines.length;
	return theme.fg("muted", `→ ${n} ${n === 1 ? forms[0] : forms[1]}`);
}

function shortOutputOrCount(txt: string, theme: Theme): string {
	const lines = nonEmptyLines(txt);
	if (lines.length === 0) return theme.fg("dim", "→ ok");
	// 短输出通常就是答案本身，直接给；长输出给计数
	if (lines.length <= 3) return theme.fg("toolOutput", lines.join("\n"));
	return theme.fg("muted", `→ ${lines.length} lines`);
}

function firstLineOr(text: string, theme: Theme, fallback: string): string {
	const first = nonEmptyLines(text)[0];
	if (!first) return theme.fg("dim", fallback);
	return theme.fg("muted", `→ ${clip(first, 90)}`);
}

// ---------------------------------------------------------------------------
// extension
// ---------------------------------------------------------------------------

export default function quietTools(pi: ExtensionAPI) {
	// --- read ---------------------------------------------------------------
	pi.registerTool(
		defineTool(createReadTool, {
			call: (a, t) => {
				let detail = t.fg("accent", shortPath(a.path ?? ""));
				if (a.offset !== undefined || a.limit !== undefined) {
					const start = a.offset ?? 1;
					const end = a.limit !== undefined ? start + a.limit - 1 : "";
					detail += t.fg("warning", `:${start}${end ? `-${end}` : ""}`);
				}
				return `${t.fg("toolTitle", t.bold("read"))} ${detail}`;
			},
			result: (txt, t) => countJudgement(txt, t, ["line", "lines"]),
		}),
	);

	// --- bash ---------------------------------------------------------------
	pi.registerTool(
		defineTool(createBashTool, {
			call: (a, t) => {
				const timeout = a.timeout ? t.fg("dim", ` (timeout ${a.timeout}s)`) : "";
				return `${t.fg("toolTitle", t.bold("bash"))} ${t.fg("toolOutput", briefCommand(a.command ?? ""))}${timeout}`;
			},
			result: shortOutputOrCount,
		}),
	);

	// --- grep ---------------------------------------------------------------
	pi.registerTool(
		defineTool(createGrepTool, {
			call: (a, t) => {
				let detail = t.fg("accent", `/${clip(a.pattern ?? "", 40)}/`);
				detail += t.fg("toolOutput", ` in ${shortPath(a.path ?? ".")}`);
				if (a.glob) detail += t.fg("dim", ` (${a.glob})`);
				return `${t.fg("toolTitle", t.bold("grep"))} ${detail}`;
			},
			result: (txt, t) => countJudgement(txt, t, ["match", "matches"], "No matches"),
		}),
	);

	// --- find ---------------------------------------------------------------
	pi.registerTool(
		defineTool(createFindTool, {
			call: (a, t) => {
				let detail = t.fg("accent", clip(a.pattern ?? "", 40));
				detail += t.fg("toolOutput", ` in ${shortPath(a.path ?? ".")}`);
				return `${t.fg("toolTitle", t.bold("find"))} ${detail}`;
			},
			result: (txt, t) => countJudgement(txt, t, ["file", "files"], "No files"),
		}),
	);

	// --- ls -----------------------------------------------------------------
	pi.registerTool(
		defineTool(createLsTool, {
			call: (a, t) =>
				`${t.fg("toolTitle", t.bold("ls"))} ${t.fg("accent", shortPath(a.path ?? "."))}`,
			result: (txt, t) => countJudgement(txt, t, ["entry", "entries"]),
		}),
	);

	// --- edit ---------------------------------------------------------------
	pi.registerTool(
		defineTool(createEditTool, {
			call: (a, t) =>
				`${t.fg("toolTitle", t.bold("edit"))} ${t.fg("accent", shortPath(a.path ?? ""))}`,
			result: (txt, t) => firstLineOr(txt, t, "→ ok"),
		}),
	);

	// --- write --------------------------------------------------------------
	pi.registerTool(
		defineTool(createWriteTool, {
			call: (a, t) => {
				const n = nonEmptyLines(a.content ?? "").length;
				const size = n > 0 ? t.fg("dim", ` (${n} lines)`) : "";
				return `${t.fg("toolTitle", t.bold("write"))} ${t.fg("accent", shortPath(a.path ?? ""))}${size}`;
			},
			result: (txt, t) =>
				nonEmptyLines(txt).length ? firstLineOr(txt, t, "→ ok") : t.fg("dim", "→ ok"),
		}),
	);
}
