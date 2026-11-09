import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdirSync, mkdtempSync, realpathSync, rmSync, symlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import test from "node:test";

/**
 * my-powerline 的滚动收起逻辑：收起输入框会把行数还给 transcript，所以必须保证
 * 收起后 pi 不会把滚动位置夹回末尾、把输入框又弹回来。
 */
const cli = realpathSync(execFileSync("which", ["pi"], { encoding: "utf8" }).trim());
const packageDir = dirname(dirname(dirname(cli)));
const extension = resolve(import.meta.dirname, "../extensions/my-powerline.ts");

const temp = mkdtempSync(join(tmpdir(), "my-powerline-test-"));
let stepComposerVisibility;
try {
  const scope = join(temp, "node_modules", "@earendil-works");
  mkdirSync(scope, { recursive: true });
  symlinkSync(packageDir, join(scope, "pi-coding-agent"));
  symlinkSync(join(packageDir, "node_modules", "@earendil-works", "pi-tui"), join(scope, "pi-tui"));
  const copy = join(temp, "my-powerline.ts");
  copyFileSync(extension, copy);
  ({ stepComposerVisibility } = await import(pathToFileURL(copy).href));
} finally {
  rmSync(temp, { recursive: true, force: true });
}

// contentHeight - viewportHeight - scrollTop === 视口下面还有多少行
const view = (below, { scrollTop = 20, viewportHeight = 20, following = false } = {}) => ({
  scrollTop,
  viewportHeight,
  contentHeight: viewportHeight + scrollTop + below,
  isFollowingEnd: following,
});

const visible = { hidden: false, lastViewportTop: 20 };
const hidden = { hidden: true, lastViewportTop: 20 };

test("跟随末尾时永不收起", () => {
  const next = stepComposerVisibility(visible, view(0, { following: true }), 4);
  assert.equal(next.hide, false);
});

test("向上滚动且下面还有超过输入框高度的行时收起", () => {
  const next = stepComposerVisibility(visible, view(10, { scrollTop: 15 }), 4);
  assert.deepEqual(next, { hidden: true, lastViewportTop: 15, hide: true });
});

test("下面只有几行时不收起，避免收起后视口变大被夹回末尾", () => {
  assert.equal(stepComposerVisibility(visible, view(4, { scrollTop: 15 }), 4).hide, false);
  assert.equal(stepComposerVisibility(visible, view(2, { scrollTop: 15 }), 4).hide, false);
});

test("收起后视口变大（below 减少）仍然保持收起", () => {
  const next = stepComposerVisibility(hidden, view(6, { scrollTop: 15, viewportHeight: 24 }), 4);
  assert.deepEqual(next, { hidden: true, lastViewportTop: 20, hide: true });
});

test("滚回末尾后自动还原", () => {
  assert.equal(stepComposerVisibility(hidden, view(0, { scrollTop: 15, viewportHeight: 24 }), 4).hide, false);
  assert.equal(stepComposerVisibility(hidden, view(9, { following: true }), 4).hide, false);
});

test("收起状态下向下滚动，只要没到底就继续收起", () => {
  const next = stepComposerVisibility(hidden, view(3, { scrollTop: 17, viewportHeight: 24 }), 4);
  assert.equal(next.hidden, true);
  assert.equal(next.hide, true);
});

test("没有向上滚动时（比如打字触发重绘）不会再次收起", () => {
  const scrolled = stepComposerVisibility(visible, view(10, { scrollTop: 15 }), 4);
  assert.equal(scrolled.hide, true, "向上滚动那一帧收起");
  const shown = { hidden: false, lastViewportTop: 15 };
  const afterTyping = stepComposerVisibility(shown, view(10, { scrollTop: 15 }), 4);
  assert.equal(afterTyping.hide, false, "输入框被按键叫回来后，不再因为重绘消失");
});

test("拿不到 contentHeight 时保持可见（宁可不动，也不要抖）", () => {
  const next = stepComposerVisibility(visible, { scrollTop: 5, viewportHeight: 20, isFollowingEnd: false }, 4);
  assert.equal(next.hide, false);
});
