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
 *
 * 实现：用 create*ToolDefinition(cwd) 的完整定义（含 promptSnippet、execute、
 * details），只替换渲染。工具内部的相对路径按每次调用的 ctx.cwd 解析，所以
 * 启动时创建一次即可，会话中途切 cwd 也不会失准。
 */

import type {
	BashToolDetails,
	EditToolDetails,
	GrepToolDetails,
	ReadToolDetails,
	Theme,
	TruncationResult,
} from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	createBashToolDefinition,
	createEditToolDefinition,
	createFindToolDefinition,
	createGrepToolDefinition,
	createLsToolDefinition,
	createReadToolDefinition,
	createWriteToolDefinition,
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
type ToolResult = { content?: Content[]; details?: unknown };
type RenderOptions = { expanded?: boolean; isPartial?: boolean };
type RenderContext = { isError?: boolean; expanded?: boolean };

function resultText(result: ToolResult | undefined): string {
	return (result?.content ?? [])
		.filter((c) => c.type === "text")
		.map((c) => c.text ?? "")
		.join("\n");
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
// 渲染原语
// ---------------------------------------------------------------------------

function isExpanded(options: RenderOptions | undefined, context: RenderContext | undefined): boolean {
	return Boolean(options?.expanded ?? context?.expanded);
}

/** 折叠态文本：以单个空格开头，接在内置工具行的指标位。 */
function folded(text: string): Text {
	return new Text(` ${text}`, 0, 0);
}

/** 展开态：交回完整原始输出，等同内置渲染器。 */
function expanded(text: string): Text {
	const body = text.trim();
	return new Text(body ? `\n${body}` : "", 0, 0);
}

/**
 * 一个工具结果渲染的骨架：错误永不折叠，展开态给全文，折叠态交给 judge。
 */
function renderResult(
	result: ToolResult,
	options: RenderOptions,
	theme: Theme,
	context: RenderContext,
	judge: (text: string, details: unknown, theme: Theme) => string | null,
): Text {
	const text = resultText(result);

	// 错误永远不折叠：静默失败比噪音更贵
	if (context?.isError) {
		const lines = nonEmptyLines(text).slice(0, 6);
		return new Text(` ${theme.fg("error", lines.join("\n") || "error")}`, 0, 0);
	}

	if (isExpanded(options, context)) return expanded(text);

	if (options?.isPartial) {
		const n = nonEmptyLines(text).length;
		return folded(theme.fg("dim", n ? `→ ${n} lines…` : "→ …"));
	}

	const rendered = judge(text, result.details, theme);
	return rendered === null ? new Text("", 0, 0) : folded(rendered);
}

function truncationNote(truncation: TruncationResult | undefined, theme: Theme): string {
	return truncation?.truncated ? theme.fg("dim", " (truncated)") : "";
}

/** 计数型判定：0 个就明说 0，别让折叠态看起来像成功。 */
function countJudgement(
	text: string,
	theme: Theme,
	forms: [singular: string, plural: string],
	zeroHint?: string,
	note = "",
): string {
	const lines = nonEmptyLines(text);
	const first = lines[0] ?? "";
	if (lines.length === 0 || (zeroHint && first.startsWith(zeroHint))) {
		return theme.fg("dim", `→ 0 ${forms[1]}`);
	}
	const n = lines.length;
	return theme.fg("muted", `→ ${n} ${n === 1 ? forms[0] : forms[1]}`) + note;
}

/** bash 这类工具：短输出通常就是答案本身；长输出只给计数。 */
function shortOutputOrCount(text: string, theme: Theme, note = ""): string {
	const lines = nonEmptyLines(text);
	if (lines.length === 0) return theme.fg("dim", `→ ok${note}`);
	if (lines.length <= 3) return theme.fg("toolOutput", lines.join("\n")) + note;
	return theme.fg("muted", `→ ${lines.length} lines`) + note;
}

function firstLineOr(text: string, theme: Theme, fallback: string): string {
	const first = nonEmptyLines(text)[0];
	if (!first) return theme.fg("dim", fallback);
	return theme.fg("muted", `→ ${clip(first, 90)}`);
}

/** edit 的判定：改动行数比"成功"两个字有信息量。 */
function diffJudgement(details: unknown, text: string, theme: Theme): string {
	const patch = (details as EditToolDetails | undefined)?.patch;
	if (!patch) return firstLineOr(text, theme, "→ ok");
	let added = 0;
	let removed = 0;
	for (const line of patch.split("\n")) {
		if (line.startsWith("+++") || line.startsWith("---")) continue;
		if (line.startsWith("+")) added++;
		else if (line.startsWith("-")) removed++;
	}
	if (added === 0 && removed === 0) return theme.fg("dim", "→ ok");
	const parts: string[] = [];
	if (added) parts.push(`+${added}`);
	if (removed) parts.push(`-${removed}`);
	return theme.fg("muted", `→ ${parts.join(" ")}`);
}

// ---------------------------------------------------------------------------
// extension
// ---------------------------------------------------------------------------

export default function quietTools(pi: ExtensionAPI) {
	const cwd = process.cwd();

	// --- read ---------------------------------------------------------------
	const read = createReadToolDefinition(cwd);
	pi.registerTool({
		...read,
		renderCall(args, theme, context) {
			const path = theme.fg("accent", shortPath(args.path ?? ""));
			const range =
				args.offset !== undefined || args.limit !== undefined
					? (() => {
							const start = args.offset ?? 1;
							const end = args.limit !== undefined ? start + args.limit - 1 : "";
							return theme.fg("warning", `:${start}${end ? `-${end}` : ""}`);
						})()
					: "";
			return new Text(`${theme.fg("toolTitle", theme.bold("read"))} ${path}${range}`, 0, 0);
		},
		renderResult(result, options, theme, context) {
			return renderResult(result, options, theme, context, (text, details, t) =>
				countJudgement(
					text,
					t,
					["line", "lines"],
					undefined,
					truncationNote((details as ReadToolDetails | undefined)?.truncation, t),
				),
			);
		},
	});

	// --- bash ---------------------------------------------------------------
	const bash = createBashToolDefinition(cwd);
	pi.registerTool({
		...bash,
		renderCall(args, theme, context) {
			const timeout = args.timeout ? theme.fg("dim", ` (timeout ${args.timeout}s)`) : "";
			const command = context?.expanded ? (args.command ?? "") : briefCommand(args.command ?? "");
			return new Text(
				`${theme.fg("toolTitle", theme.bold("bash"))} ${theme.fg("toolOutput", command)}${timeout}`,
				0,
				0,
			);
		},
		renderResult(result, options, theme, context) {
			return renderResult(result, options, theme, context, (text, details, t) =>
				shortOutputOrCount(text, t, truncationNote((details as BashToolDetails | undefined)?.truncation, t)),
			);
		},
	});

	// --- grep ---------------------------------------------------------------
	const grep = createGrepToolDefinition(cwd);
	pi.registerTool({
		...grep,
		renderCall(args, theme) {
			let detail = theme.fg("accent", `/${clip(args.pattern ?? "", 40)}/`);
			detail += theme.fg("toolOutput", ` in ${shortPath(args.path ?? ".")}`);
			if (args.glob) detail += theme.fg("dim", ` (${args.glob})`);
			return new Text(`${theme.fg("toolTitle", theme.bold("grep"))} ${detail}`, 0, 0);
		},
		renderResult(result, options, theme, context) {
			return renderResult(result, options, theme, context, (text, details, t) =>
				countJudgement(
					text,
					t,
					["match", "matches"],
					"No matches",
					truncationNote((details as GrepToolDetails | undefined)?.truncation, t),
				),
			);
		},
	});

	// --- find ---------------------------------------------------------------
	const find = createFindToolDefinition(cwd);
	pi.registerTool({
		...find,
		renderCall(args, theme) {
			let detail = theme.fg("accent", clip(args.pattern ?? "", 40));
			detail += theme.fg("toolOutput", ` in ${shortPath(args.path ?? ".")}`);
			return new Text(`${theme.fg("toolTitle", theme.bold("find"))} ${detail}`, 0, 0);
		},
		renderResult(result, options, theme, context) {
			return renderResult(result, options, theme, context, (text, _details, t) =>
				countJudgement(text, t, ["file", "files"], "No files"),
			);
		},
	});

	// --- ls -----------------------------------------------------------------
	const ls = createLsToolDefinition(cwd);
	pi.registerTool({
		...ls,
		renderCall(args, theme) {
			return new Text(
				`${theme.fg("toolTitle", theme.bold("ls"))} ${theme.fg("accent", shortPath(args.path ?? "."))}`,
				0,
				0,
			);
		},
		renderResult(result, options, theme, context) {
			return renderResult(result, options, theme, context, (text, _details, t) =>
				countJudgement(text, t, ["entry", "entries"]),
			);
		},
	});

	// --- edit ---------------------------------------------------------------
	const edit = createEditToolDefinition(cwd);
	pi.registerTool({
		...edit,
		renderCall(args, theme) {
			return new Text(
				`${theme.fg("toolTitle", theme.bold("edit"))} ${theme.fg("accent", shortPath(args.path ?? ""))}`,
				0,
				0,
			);
		},
		renderResult(result, options, theme, context) {
			// 折叠态用 ±行数，展开态给内置 diff
			if (isExpanded(options, context) && !context?.isError) {
				const diff = (result.details as EditToolDetails | undefined)?.diff;
				if (diff) return new Text(`\n${diff}`, 0, 0);
			}
			return renderResult(result, options, theme, context, (text, details, t) =>
				diffJudgement(details, text, t),
			);
		},
	});

	// --- write --------------------------------------------------------------
	const write = createWriteToolDefinition(cwd);
	pi.registerTool({
		...write,
		renderCall(args, theme) {
			const n = nonEmptyLines(args.content ?? "").length;
			const size = n > 0 ? theme.fg("dim", ` (${n} lines)`) : "";
			return new Text(
				`${theme.fg("toolTitle", theme.bold("write"))} ${theme.fg("accent", shortPath(args.path ?? ""))}${size}`,
				0,
				0,
			);
		},
		renderResult(result, options, theme, context) {
			return renderResult(result, options, theme, context, (text, _details, t) =>
				firstLineOr(text, t, "→ ok"),
			);
		},
	});
}
