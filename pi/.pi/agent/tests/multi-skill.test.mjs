import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdirSync, mkdtempSync, realpathSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import test from "node:test";

/**
 * 直接加载真实扩展，喂假的 pi / ctx，验证 input 阶段的展开结果。
 * 解析环境同 quiet-tools.test.mjs：用 node_modules 软链模拟 pi 的包解析。
 */
const cli = realpathSync(execFileSync("which", ["pi"], { encoding: "utf8" }).trim());
const packageDir = dirname(dirname(dirname(cli)));
const extension = resolve(import.meta.dirname, "../extensions/multi-skill.ts");

const temp = mkdtempSync(join(tmpdir(), "multi-skill-test-"));
let mod;
try {
	const scope = join(temp, "node_modules", "@earendil-works");
	mkdirSync(scope, { recursive: true });
	symlinkSync(packageDir, join(scope, "pi-coding-agent"));
	const copy = join(temp, "multi-skill.ts");
	copyFileSync(extension, copy);
	mod = await import(pathToFileURL(copy).href);
} finally {
	rmSync(temp, { recursive: true, force: true });
}

const { default: register, parseSkillChain, formatSkillChain } = mod;

// --- 假环境 ---------------------------------------------------------------

const skillDir = mkdtempSync(join(tmpdir(), "multi-skill-skills-"));
function makeSkill(name, body) {
	const dir = join(skillDir, name);
	mkdirSync(dir, { recursive: true });
	const filePath = join(dir, "SKILL.md");
	writeFileSync(filePath, `---\nname: ${name}\ndescription: ${name} skill\n---\n\n${body}\n`);
	return { name, description: `${name} skill`, filePath, baseDir: dir, disableModelInvocation: true };
}

const grill = makeSkill("grilling", "Interview relentlessly.");
const docs = makeSkill("domain-modeling", "Write a glossary.");

const skills = [grill, docs];

function setup() {
	const handlers = new Map();
	register({
		on: (event, handler) => handlers.set(event, handler),
		registerTool: () => {},
	});
	handlers.get("before_agent_start")({
		systemPromptOptions: { skills },
	});
	const notices = [];
	const ctx = { cwd: skillDir, ui: { notify: (msg, level) => notices.push([msg, level]) } };
	const input = (text) => handlers.get("input")({ type: "input", text, source: "interactive" }, ctx);
	return { input, notices };
}

// --- 解析 -----------------------------------------------------------------

test("parses a chain of skill tokens and the trailing args", () => {
	assert.deepEqual(parseSkillChain("/skill:grilling /skill:domain-modeling 这个方案行不行？"), {
		names: ["grilling", "domain-modeling"],
		args: "这个方案行不行？",
	});
});

test("tolerates extra whitespace and newlines between tokens", () => {
	assert.deepEqual(parseSkillChain("  /skill:a\n\n/skill:b   rest  "), { names: ["a", "b"], args: "rest" });
});

test("a skill name must end at whitespace, not be a prefix match", () => {
	assert.deepEqual(parseSkillChain("/skill:grillingx rest"), { names: ["grillingx"], args: "rest" });
});

test("returns null when the message does not start with a skill command", () => {
	assert.equal(parseSkillChain("看一下 /skill:grilling"), null);
	assert.equal(parseSkillChain(""), null);
});

test("dedupes repeated skill tokens", () => {
	assert.deepEqual(parseSkillChain("/skill:a /skill:a x"), { names: ["a"], args: "x" });
});

// --- 展开 -----------------------------------------------------------------

test("a single skill is left to pi's own expansion", () => {
	const { input } = setup();
	assert.deepEqual(input("/skill:grilling why?"), { action: "continue" });
});

test("two skills expand into one parsable skill block", () => {
	const { input } = setup();
	const result = input("/skill:grilling /skill:domain-modeling 这个方案行不行？");
	assert.equal(result.action, "transform");

	// pi 的 parseSkillBlock 正则要求整条消息就是一个块，且 name/location 都在头部
	const match = result.text.match(/^<skill name="([^"]+)" location="([^"]+)">\n([\s\S]*?)\n<\/skill>(?:\n\n([\s\S]+))?$/);
	assert.ok(match, "expanded text must match pi's skill-block shape");
	assert.equal(match[1], "grilling + domain-modeling");
	assert.equal(match[4], "这个方案行不行？");

	// 两份正文都在，且各自带上自己的目录说明
	assert.match(match[3], /## grilling\nReferences are relative to .*grilling\.\n\nInterview relentlessly\./);
	assert.match(match[3], /## domain-modeling\nReferences are relative to .*domain-modeling\.\n\nWrite a glossary\./);

	// frontmatter 不该漏进上下文
	assert.ok(!match[3].startsWith("---"));
	assert.doesNotMatch(match[3], /^name: /m);
	assert.doesNotMatch(match[3], /disable-model-invocation/);
});

test("order follows the typed order, not the skill list order", () => {
	const { input } = setup();
	const result = input("/skill:domain-modeling /skill:grilling");
	assert.match(result.text, /^<skill name="domain-modeling \+ grilling"/);
});

test("unknown skills are reported and pi's single expansion is left in charge", () => {
	const { input, notices } = setup();
	assert.deepEqual(input("/skill:grilling /skill:nope x"), { action: "continue" });
	assert.deepEqual(notices, [["unknown skill: nope", "error"]]);
});

test("messages that are not skill chains pass through untouched", () => {
	const { input } = setup();
	assert.deepEqual(input("帮我 grill 一下这个方案"), { action: "continue" });
});

// formatSkillChain 单独可用（不含 args 时不追加空行）
test("omits the trailing user message when there are no args", () => {
	const text = formatSkillChain([grill], "  ");
	assert.match(text, /\n<\/skill>$/);
});
