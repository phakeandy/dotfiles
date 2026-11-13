/**
 * multi-skill — 一条消息里同时展开多个 `/skill:<name>`。
 *
 * pi 自带的展开（agent-session 的 `_expandSkillCommand`）只看消息开头的**第一个**
 * `/skill:<name>`，后面的同形 token 会被当成参数原样塞给第一个 skill。所以
 * "拉起另一个 skill 一起干活"的组合技能（grill-with-docs 那种）没法从命令行触发。
 *
 * 这个扩展在 input 阶段拦截（此时 command 已匹配、skill 展开还没发生），把开头连续的
 * 多个 `/skill:` 一次性展开：
 *
 *   /skill:grilling /skill:domain-modeling 这个方案行不行？
 *
 * 展开结果仍是**单个** `<skill ...>` 块，名字写成 `a + b`：这样 pi 的
 * `parseSkillBlock` 能认出来，transcript 里折叠成一行 `[skill] a + b`，
 * 而不是把两份 SKILL.md 全文糊在聊天里。每段内容各自带自己的目录说明，
 * 相对路径照旧按各自 skill 目录解析。
 *
 * 名单来源：`before_agent_start` 的 systemPromptOptions.skills（权威，含
 * disable-model-invocation 的 skill）。会话第一条消息时它还没到，退回到按
 * pi 的默认目录扫一遍。
 */

import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { existsSync, readFileSync } from "node:fs";
import { CONFIG_DIR_NAME, getAgentDir, loadSkillsFromDir, stripFrontmatter } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI, Skill } from "@earendil-works/pi-coding-agent";

const SKILL_TOKEN = /^\/skill:([a-z0-9][a-z0-9-]*)(?=\s|$)/;

export interface SkillChain {
	/** 按输入顺序、去重后的 skill 名。 */
	names: string[];
	/** 所有 `/skill:` token 之后的剩余文本。 */
	args: string;
}

/** 解析消息开头的连续 skill 命令。没有 `/skill:` 开头时返回 null。 */
export function parseSkillChain(text: string): SkillChain | null {
	let rest = text.trimStart();
	const names: string[] = [];
	while (true) {
		const match = rest.match(SKILL_TOKEN);
		if (!match) break;
		if (!names.includes(match[1])) names.push(match[1]);
		rest = rest.slice(match[0].length).trimStart();
	}
	return names.length > 0 ? { names, args: rest.trim() } : null;
}

/**
 * 拼成单个 skill 块。格式必须和 pi 自己的展开一致（`parseSkillBlock` 用正则锚定整条消息）：
 * `<skill name="..." location="...">\n...\n</skill>`
 */
export function formatSkillChain(skills: Array<Pick<Skill, "name" | "filePath" | "baseDir">>, args: string): string {
	const body = skills
		.map((skill) => {
			const content = stripFrontmatter(readFileSync(skill.filePath, "utf-8")).trim();
			return `## ${skill.name}\nReferences are relative to ${skill.baseDir}.\n\n${content}`;
		})
		.join("\n\n---\n\n");

	const head = `<skill name="${skills.map((s) => s.name).join(" + ")}" location="${skills
		.map((s) => s.filePath)
		.join(" + ")}">`;
	const block = `${head}\n${body}\n</skill>`;
	const userMessage = args.trim();
	return userMessage ? `${block}\n\n${userMessage}` : block;
}

/** pi 默认会扫的 skill 目录，按优先级。 */
function skillRoots(cwd: string): string[] {
	const roots = [
		join(getAgentDir(), "skills"),
		join(cwd, CONFIG_DIR_NAME, "skills"),
		join(homedir(), ".agents", "skills"),
	];
	// 项目 .agents/skills：从 cwd 向上到仓库根（含）。
	let dir = cwd;
	while (true) {
		roots.push(join(dir, ".agents", "skills"));
		if (existsSync(join(dir, ".git"))) break;
		const parent = dirname(dir);
		if (parent === dir) break;
		dir = parent;
	}
	return roots;
}

export default function multiSkill(pi: ExtensionAPI) {
	const known = new Map<string, Skill>();

	const remember = (skills: readonly Skill[] | undefined): void => {
		for (const skill of skills ?? []) known.set(skill.name, skill);
	};

	// 权威名单，每轮刷新（含 disable-model-invocation 的 skill）。
	pi.on("before_agent_start", (event) => {
		remember(event.systemPromptOptions.skills);
	});

	const lookup = (name: string, cwd: string): Skill | undefined => {
		const cached = known.get(name);
		if (cached) return cached;
		// 会话第一条消息时 before_agent_start 还没跑过，按默认目录兜一次。
		for (const root of skillRoots(cwd)) {
			remember(loadSkillsFromDir({ dir: root, source: "multi-skill" }).skills);
			const found = known.get(name);
			if (found) return found;
		}
		return undefined;
	};

	pi.on("input", (event, ctx) => {
		const chain = parseSkillChain(event.text);
		// 只有一个 skill 就交给 pi 自己展开，行为完全一致。
		if (!chain || chain.names.length < 2) return { action: "continue" };

		const skills: Skill[] = [];
		const missing: string[] = [];
		for (const name of chain.names) {
			const skill = lookup(name, ctx.cwd);
			if (skill) skills.push(skill);
			else missing.push(name);
		}

		if (missing.length > 0) {
			ctx.ui.notify(`unknown skill: ${missing.join(", ")}`, "error");
			return { action: "continue" };
		}

		return { action: "transform", text: formatSkillChain(skills, chain.args) };
	});
}
