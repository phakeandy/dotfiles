/**
 * transcript — 把当前分支渲染成一份 Markdown，用 $EDITOR 打开。
 *
 * 为什么用 getBranch 而不是 getEntries：getEntries 是整个文件（含你切走的分支、
 * 被 /tree 遗弃的路径），getBranch 只走当前 leaf 到 root 这一条，也就是你实际看到的
 * 对话。因为它不经过 compaction 投影，历史上的原话仍然完整保留，适合搜索。
 *
 * 为什么每次覆盖同一个文件：这是一份快照，不是工作区。按行号/内容做缓存 key
 * 会在 session 文件被重写（v1→v3 迁移）后给出过期内容，故意不缓存。
 *
 * ctrl+s 原本是 app.models.save，不在保留键位表里，所以扩展会覆盖它
 * （pi 启动时给一条 diagnostic 警告，属预期）。不想要就把 SHORTCUT 改成别的。
 */

import { spawn } from "node:child_process";
import { mkdir, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import type { AgentMessage } from "@earendil-works/pi-agent-core";
import type {
	ExtensionAPI,
	ExtensionCommandContext,
	ExtensionContext,
	SessionEntry,
	SessionHeader,
} from "@earendil-works/pi-coding-agent";
import { stripTerminalSequences } from "@earendil-works/pi-tui";

const COMMAND = "transcript";
const SHORTCUT = "ctrl+s";

/** 围栏长度比内容里最长的反引号多一，内容里带 ``` 也不会提前闭合。 */
function fence(value: string, lang = ""): string {
	const longest = Math.max(3, ...Array.from(value.matchAll(/`+/g), (match) => match[0].length + 1));
	const ticks = "`".repeat(longest);
	return `${ticks}${lang}\n${value}\n${ticks}`;
}

function clock(timestamp: number | string | undefined): string {
	if (timestamp === undefined) return "";
	const date = new Date(timestamp);
	if (Number.isNaN(date.getTime())) return "";
	return date.toTimeString().slice(0, 8);
}

function quote(value: unknown): string {
	return JSON.stringify(value ?? null);
}

/** 一段 = 一个标题 + 它的正文；段与段之间恰好一个空行。 */
function push(out: string[], heading: string, body?: string): void {
	const text = body === undefined ? heading : `${heading}\n\n${body.trim()}`;
	if (text.trim()) out.push(text.trimEnd());
}

/** message.content 既可能是字符串，也可能是内容块数组。 */
function textBlocks(content: unknown): string {
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";
	const parts: string[] = [];
	for (const block of content) {
		if (block?.type === "text" && typeof block.text === "string") parts.push(block.text);
		else if (block?.type === "image") parts.push(`[image: ${String(block.mimeType ?? "unknown")}]`);
	}
	return parts.join("\n\n");
}

function toolArguments(args: Record<string, unknown> | undefined, name: string): string {
	const entries = Object.entries(args ?? {});
	const command = entries.find(([key]) => key === "command")?.[1];
	if ((name === "bash" || name === "shell") && typeof command === "string") {
		const rest = Object.fromEntries(entries.filter(([key]) => key !== "command"));
		const body = Object.keys(rest).length === 0 ? "" : `\n\nArguments:\n\n${fence(JSON.stringify(rest, null, 2), "json")}`;
		return `${fence(command, "sh")}${body}`;
	}
	return fence(JSON.stringify(args ?? {}, null, 2), "json");
}

function renderMessage(message: AgentMessage, out: string[], turn: { value: number }): void {
	switch (message.role) {
		case "user": {
			turn.value += 1;
			const body = message.content === undefined ? "" : typeof message.content === "string" ? message.content : textBlocks(message.content);
			push(out, `## Turn ${turn.value} · User · ${clock(message.timestamp)}`, body.trimEnd());
			return;
		}
		case "assistant": {
			push(out, `## Assistant · ${clock(message.timestamp)}`);
			for (const block of message.content) {
				if (block.type === "text") {
					if (block.text.trim()) push(out, block.text.trimEnd());
				} else if (block.type === "thinking") {
					if (block.thinking.trim()) push(out, "#### Thinking", block.thinking.trimEnd());
				} else if (block.type === "toolCall") {
					push(out, `### Tool call · ${block.name}`, toolArguments(block.arguments, block.name));
				}
			}
			if (message.errorMessage) push(out, `> error: ${message.errorMessage}`);
			return;
		}
		case "toolResult": {
			const suffix = message.isError ? " (error)" : "";
			const body = stripTerminalSequences(textBlocks(message.content)).trimEnd();
			// 工具输出常常自带 Markdown 标题，包进围栏，避免污染本文档的目录结构。
			push(out, `### Tool result · ${message.toolName}${suffix}`, fence(body, "text"));
			return;
		}
		case "bashExecution": {
			push(out, `### Bash · ${message.command}`, fence(stripTerminalSequences(String(message.output ?? "")).trimEnd(), "text"));
			return;
		}
		case "system":
			return;
		default: {
			const custom = message as { role: string; content?: unknown; customType?: string };
			const label = custom.customType ? `${custom.role} · ${custom.customType}` : custom.role;
			push(out, `### ${label}`, textBlocks(custom.content).trimEnd());
		}
	}
}

function renderEntry(entry: SessionEntry, out: string[], turn: { value: number }): void {
	switch (entry.type) {
		case "message":
			renderMessage(entry.message, out, turn);
			return;
		case "model_change":
			push(out, `> model → ${entry.provider}/${entry.modelId}`);
			return;
		case "thinking_level_change":
			push(out, `> thinking → ${entry.thinkingLevel}`);
			return;
		case "compaction":
			push(out, `## Compaction · ${clock(entry.timestamp)}`, String(entry.summary).trimEnd());
			return;
		case "branch_summary":
			push(out, `## Branch summary · ${clock(entry.timestamp)}`, String(entry.summary).trimEnd());
			return;
		case "custom":
			push(out, `### Custom · ${entry.customType}`, fence(JSON.stringify(entry.data ?? null, null, 2), "json"));
			return;
		default:
			return;
	}
}

export interface TranscriptInput {
	entries: SessionEntry[];
	header: SessionHeader | null;
	name?: string;
	file?: string;
	model?: string;
	exportedAt?: Date;
}

/** 纯函数：给一份分支，返回 Markdown。方便单测和 CLI 复用。 */
export function renderTranscript(input: TranscriptInput): string {
	const out = ["---"];
	if (input.header) {
		out.push(`session: ${quote(input.header.id)}`);
		out.push(`cwd: ${quote(input.header.cwd)}`, `started: ${quote(input.header.timestamp)}`);
	}
	if (input.name) out.push(`name: ${quote(input.name)}`);
	if (input.file) out.push(`file: ${quote(input.file)}`);
	if (input.model) out.push(`model: ${quote(input.model)}`);
	out.push(`exported: ${quote((input.exportedAt ?? new Date()).toISOString())}`);
	out.push(`entries: ${input.entries.length}`, "---");

	const body = ["# pi transcript"];
	const turn = { value: 0 };
	for (const entry of input.entries) renderEntry(entry, body, turn);

	return `${out.join("\n")}\n\n${body.join("\n\n")}\n`;
}

function editorCommand(): string {
	return process.env.VISUAL?.trim() || process.env.EDITOR?.trim() || "vi";
}

function runEditor(command: string, file: string): Promise<void> {
	return new Promise((resolve, reject) => {
		// command 来自用户自己的环境变量；路径走 $1，不会被当成 shell 代码。
		const child = spawn("sh", ["-c", `exec ${command} "$1"`, "sh", file], { stdio: "inherit" });
		child.once("error", reject);
		child.once("exit", (code, signal) => {
			if (code === 0) resolve();
			else reject(new Error(`editor exited with ${signal ?? `status ${code}`}`));
		});
	});
}

async function openTranscript(ctx: ExtensionContext | ExtensionCommandContext): Promise<void> {
	if (ctx.mode !== "tui") {
		ctx.ui.notify(`/${COMMAND} needs the interactive terminal`, "warning");
		return;
	}
	const file = ctx.sessionManager.getSessionFile();
	if (!file) {
		ctx.ui.notify(`this session has no file on disk`, "warning");
		return;
	}

	const entries = ctx.sessionManager.getBranch();
	const header = ctx.sessionManager.getHeader();
	const model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : undefined;
	const markdown = renderTranscript({
		entries,
		header,
		name: ctx.sessionManager.getSessionName(),
		file,
		model,
	});

	// 覆盖写：快照语义。0600 + 私有目录，path 只由 session id 决定。
	const target = join(tmpdir(), "pi-transcript", `${ctx.sessionManager.getSessionId()}.md`);
	await mkdir(dirname(target), { recursive: true, mode: 0o700 });
	await writeFile(target, markdown, { mode: 0o600 });

	const command = editorCommand();
	await ctx.ui.custom<void>((tui, _theme, _keys, done) => {
		tui.stop();
		void runEditor(command, target)
			.catch((error: unknown) => {
				ctx.ui.notify(`${COMMAND}: ${error instanceof Error ? error.message : String(error)}`, "error");
			})
			.finally(() => {
				tui.start();
				tui.requestRender(true);
				done();
			});
		return { render: () => [], invalidate: () => {} };
	});
}

export default function transcript(pi: ExtensionAPI): void {
	pi.registerCommand(COMMAND, {
		description: "Render this branch as Markdown and open it in $EDITOR",
		handler: (_args, ctx) => openTranscript(ctx),
	});
	pi.registerShortcut(SHORTCUT, {
		description: "Open transcript in $EDITOR",
		handler: (ctx) => openTranscript(ctx),
	});
}
