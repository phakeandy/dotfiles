import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, realpathSync, rmSync, symlinkSync, copyFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import test from "node:test";

// Load the actual extension with the same packages used by the installed pi.
const shim = execFileSync("which", ["pi"], { encoding: "utf8" }).trim();
const target = readFileSync(shim, "utf8").match(/^# cmd-shim-target=(.+)$/m)?.[1];
assert.ok(target, "Cannot locate pi package from its shell shim");
const packageDir = dirname(dirname(dirname(target)));
const modules = dirname(dirname(realpathSync(packageDir)));
const extension = resolve(import.meta.dirname, "../extensions/quiet-tools.ts");
const temp = mkdtempSync(join(tmpdir(), "quiet-tools-test-"));
let tools;
try {
  symlinkSync(modules, join(temp, "node_modules"));
  const copy = join(temp, "quiet-tools.ts");
  copyFileSync(extension, copy);
  const { default: register } = await import(pathToFileURL(copy).href);
  tools = new Map();
  register({ registerTool(tool) { tools.set(tool.name, tool); } });
} finally {
  rmSync(temp, { recursive: true, force: true });
}

const theme = { fg: (_color, text) => text, bold: text => text };
const render = (command, expanded) =>
  tools.get("bash").renderCall({ command }, theme, { expanded })
    .render(1000).map(line => line.trimEnd()).join("\n");

test("bash call shows the full original command on expansion and shortens it when collapsed", () => {
  const command = `cd /a/very/long/project/path && echo "${"long ".repeat(30)}"`;
  const collapsed = render(command, false);
  assert.ok(collapsed.includes("…"), collapsed);
  assert.ok(!collapsed.includes("cd /a/very/long/project/path"), collapsed);
  assert.equal(render(command, true), `bash ${command}`);
  assert.equal(render(command, false), collapsed);
});

test("expanded bash call preserves newlines in the command", () => {
  const command = 'set -u\nprintf "%s\\n" "hello"';
  assert.equal(render(command, true), `bash ${command}`);
});
