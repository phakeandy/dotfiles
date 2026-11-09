import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdirSync, mkdtempSync, realpathSync, rmSync, symlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import test from "node:test";

/**
 * 加载真实扩展（用已安装的 pi 提供的包），然后直接调用渲染函数。
 * pi 的扩展加载器会给扩展注入 @earendil-works/pi-tui 的别名，
 * 这里用 node_modules 软链模拟同样的解析环境。
 */
const cli = realpathSync(execFileSync("which", ["pi"], { encoding: "utf8" }).trim());
const packageDir = dirname(dirname(dirname(cli)));
const modules = dirname(dirname(packageDir));
const extension = resolve(import.meta.dirname, "../extensions/quiet-tools.ts");

const piTui = join(packageDir, "node_modules", "@earendil-works", "pi-tui");
assert.ok(modules && piTui, "Cannot locate the installed pi packages");

const temp = mkdtempSync(join(tmpdir(), "quiet-tools-test-"));
let tools;
try {
  // node_modules/@earendil-works -> 本地作用域目录，里面放 pi 的两个包
  const scope = join(temp, "node_modules", "@earendil-works");
  mkdirSync(scope, { recursive: true });
  symlinkSync(packageDir, join(scope, "pi-coding-agent"));
  symlinkSync(piTui, join(scope, "pi-tui"));
  const copy = join(temp, "quiet-tools.ts");
  copyFileSync(extension, copy);
  const { default: register } = await import(pathToFileURL(copy).href);
  tools = new Map();
  register({ registerTool: (tool) => tools.set(tool.name, tool) });
} finally {
  rmSync(temp, { recursive: true, force: true });
}

const theme = { fg: (_color, text) => text, bold: (text) => text };
const paint = (component) =>
  component
    .render(1000)
    .map((line) => line.trimEnd())
    .join("\n")
    .trim();

const call = (name, args, expanded = false) =>
  paint(tools.get(name).renderCall(args, theme, { expanded, isError: false }));
const result = (name, res, { expanded = false, isError = false } = {}) =>
  paint(tools.get(name).renderResult(res, { expanded, isPartial: false }, theme, { expanded, isError }));
const text = (value, details) => ({ content: [{ type: "text", text: value }], details });

test("注册了全部被覆盖的内置工具", () => {
  assert.deepEqual([...tools.keys()].sort(), ["bash", "edit", "find", "grep", "ls", "read", "write"]);
});

test("bash 调用折叠时剥掉 cd 前缀，展开时保留完整命令", () => {
  const command = `cd /a/very/long/project/path && echo "${"long ".repeat(30)}"`;
  const collapsed = call("bash", { command });
  assert.ok(collapsed.includes("…"), collapsed);
  assert.ok(!collapsed.includes("cd /a/very/long/project/path"), collapsed);
  assert.equal(call("bash", { command }, true), `bash ${command}`);
});

test("bash 调用展开时保留命令中的换行", () => {
  const command = 'set -u\nprintf "%s\\n" "hello"';
  assert.equal(call("bash", { command }, true), `bash ${command}`);
});

test("折叠态用计数代替输出：短输出直接给，长输出给行数", () => {
  assert.equal(result("bash", text("")), "→ ok");
  assert.equal(result("bash", text("1\n2\n3\n")), "1\n2\n3");
  assert.equal(result("bash", text("1\n2\n3\n4\n")), "→ 4 lines");
});

test("read 折叠态给行数，展开态给全文", () => {
  assert.equal(result("read", text("a\nb\nc\n")), "→ 3 lines");
  assert.equal(result("read", text("a\nb\nc\n", { truncation: { truncated: true } })), "→ 3 lines (truncated)");
  assert.equal(result("read", text("a\nb\nc\n"), { expanded: true }), "a\nb\nc");
});

test("grep 折叠态给匹配数，无匹配时明说 0", () => {
  assert.equal(result("grep", text("a:1:x\nb:2:y\n")), "→ 2 matches");
  assert.equal(result("grep", text("a:1:x\n")), "→ 1 match");
  assert.equal(result("grep", text("No matches found\n")), "→ 0 matches");
});

test("错误永不折叠", () => {
  assert.equal(result("bash", text("boom\nstack"), { isError: true }), "boom\nstack");
});

test("edit 折叠态给 ±行数，展开态给 diff", () => {
  const details = { patch: "--- a\n+++ b\n@@ -1 +1,2 @@\n-a\n+b\n+c\n", diff: "-a\n+b\n+c" };
  assert.equal(result("edit", text("Edited x.ts", details)), "→ +2 -1");
  assert.equal(result("edit", text("Edited x.ts", details), { expanded: true }), "-a\n+b\n+c");
});
