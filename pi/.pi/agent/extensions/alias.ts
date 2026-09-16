/**
 * alias — 通用命令别名。
 *
 * 为什么不是真正的转发：内置命令（/new、/thinking、/model…）在 interactive mode
 * 的编辑器提交阶段就被硬编码拦截，扩展拿不到转发入口；而扩展命令的匹配又排在
 * 这些内置命令之后。因此每个别名落地为一段"等效实现"，而不是把输入原文递给目标。
 *
 * 需要往对话里打印信息时用 appendEntry + registerEntryRenderer：它显示在 chat 里但不进
 * LLM 上下文（sendMessage 会进上下文），代价是条目会随 session 持久化。
 *
 * 新增别名：在 createAliases() 的表里加一项即可。
 */

import { getSupportedThinkingLevels } from "@earendil-works/pi-ai";
import type {
	ExtensionAPI,
	ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";
import { Box, Text } from "@earendil-works/pi-tui";

interface Alias {
	/** 被模拟的内置命令，仅用于说明。 */
	target: string;
	description: string;
	/** 参数补全候选；prefix 是命令名之后的文本。 */
	complete?: (prefix: string) => string[];
	run: (args: string, ctx: ExtensionCommandContext) => void | Promise<void>;
}

const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"];

// /context 的卡片内容：显示在 chat 里，但不进 LLM 上下文。
const CONTEXT_CARD_TYPE = "alias:context";

interface ContextCard {
	lines: string[];
}

function contextLines(ctx: ExtensionCommandContext): string[] {
	let user = 0;
	let assistant = 0;
	let toolResults = 0;
	let toolCalls = 0;

	for (const entry of ctx.sessionManager.getEntries()) {
		if (entry.type !== "message") continue;
		const message = entry.message;
		if (message.role === "user") {
			user += 1;
		} else if (message.role === "assistant") {
			assistant += 1;
			toolCalls += message.content.filter((block) => block.type === "toolCall").length;
		} else if (message.role === "toolResult") {
			toolResults += 1;
		}
	}

	const row = (label: string, value: string) => `${label.padEnd(8)} ${value}`;
	const usage = ctx.getContextUsage();
	const lines = [
		"Session / Context",
		"",
		row("Name", ctx.sessionManager.getSessionName() ?? "-"),
		row("Model", ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "-"),
		row("Session", ctx.sessionManager.getSessionId()),
		row("File", ctx.sessionManager.getSessionFile() ?? "in-memory"),
		row("Messages", `${user + assistant + toolResults} (${user} user, ${assistant} assistant, ${toolResults} results)`),
		row("Tools", `${toolCalls} calls`),
		"",
	];

	if (usage) {
		const used = usage.tokens;
		const percent = usage.percent === null ? "" : `  (${usage.percent.toFixed(1)}%)`;
		lines.push(
			row(
				"Context",
				used === null
					? `unknown / ${usage.contextWindow.toLocaleString()} tokens`
					: `${used.toLocaleString()} / ${usage.contextWindow.toLocaleString()} tokens${percent}`,
			),
		);
		if (used !== null) {
			lines.push(row("Free", `${Math.max(0, usage.contextWindow - used).toLocaleString()} tokens`));
		}
	} else {
		lines.push(row("Context", "unavailable"));
	}

	return lines;
}

export default function (pi: ExtensionAPI) {
	const aliases: Record<string, Alias> = {
		// /clear -> /new
		clear: {
			target: "/new",
			description: "Start a new session (same as /new)",
			run: async (_args, ctx) => {
				await ctx.newSession({
					withSession: async (newCtx) => {
						newCtx.ui.notify("✓ New session started", "info");
					},
				});
			},
		},

		// /effort -> /thinking
		effort: {
			target: "/thinking",
			description: "Switch thinking level (same as /thinking)",
			complete: (prefix) => THINKING_LEVELS.filter((level) => level.startsWith(prefix)),
			run: async (args, ctx) => {
				const available = ctx.model ? getSupportedThinkingLevels(ctx.model) : THINKING_LEVELS;
				const wanted = args.trim().toLowerCase();

				if (wanted) {
					const level = available.find((candidate) => candidate === wanted);
					if (!level) {
						ctx.ui.notify(
							`Unknown thinking level "${args}". Available: ${available.join(", ")}`,
							"error",
						);
						return;
					}
					pi.setThinkingLevel(level);
					ctx.ui.notify(`Thinking level: ${level}`, "info");
					return;
				}

				const current = pi.getThinkingLevel();
				const labels = available.map((level) => (level === current ? `${level}  (current)` : level));
				const choice = await ctx.ui.select(`Thinking level (current: ${current})`, labels);
				if (choice === undefined) return;

				const level = available[labels.indexOf(choice)];
				if (!level) return;
				pi.setThinkingLevel(level);
				ctx.ui.notify(`Thinking level: ${level}`, "info");
			},
		},

		// /context -> /session
		context: {
			target: "/session",
			description: "Show session and context info (same as /session)",
			run: (_args, ctx) => {
				pi.appendEntry<ContextCard>(CONTEXT_CARD_TYPE, { lines: contextLines(ctx) });
			},
		},
	};

	pi.registerEntryRenderer<ContextCard>(CONTEXT_CARD_TYPE, (entry, _options, theme) => {
		const lines = entry.data?.lines ?? ["Session / Context", "", "(no data)"];
		const box = new Box(1, 1, (text) => theme.bg("customMessageBg", text));
		box.addChild(new Text(theme.fg("accent", lines[0] ?? ""), 0, 0));
		for (const line of lines.slice(1)) {
			box.addChild(new Text(line, 0, 0));
		}
		return box;
	});

	for (const [name, alias] of Object.entries(aliases)) {
		pi.registerCommand(name, {
			description: alias.description,
			...(alias.complete && {
				getArgumentCompletions: (prefix: string) => {
					const items = alias.complete!(prefix).map((value) => ({ value, label: value }));
					return items.length > 0 ? items : null;
				},
			}),
			handler: async (args, ctx) => {
				await alias.run(args, ctx);
			},
		});
	}
}
