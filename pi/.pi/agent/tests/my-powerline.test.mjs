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
let composerMinSize;
let estimateTokens;
let formatSpeed;
let speedBegin;
let speedDelta;
let speedEnd;
let speedReading;
try {
  const scope = join(temp, "node_modules", "@earendil-works");
  mkdirSync(scope, { recursive: true });
  symlinkSync(packageDir, join(scope, "pi-coding-agent"));
  symlinkSync(join(packageDir, "node_modules", "@earendil-works", "pi-tui"), join(scope, "pi-tui"));
  const copy = join(temp, "my-powerline.ts");
  copyFileSync(extension, copy);
  ({
    stepComposerVisibility,
    composerMinSize,
    estimateTokens,
    formatSpeed,
    speedBegin,
    speedDelta,
    speedEnd,
    speedReading,
  } = await import(pathToFileURL(copy).href));
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

test("可见时 dock 的最小高度不超过实际渲染行数（否则多出一行空白）", () => {
  assert.equal(composerMinSize(false, 2, 3), 2, "单行输入框只渲染两行（顶边 + 输入行）");
  assert.equal(composerMinSize(false, 4, 3), 3, "多行输入时保留 pi 原本的下限");
  assert.equal(composerMinSize(false, 2, undefined), 0, "pi 没设下限时也不要凭空加一行");
});

test("收起时最小高度归零，行数还给 transcript", () => {
  assert.equal(composerMinSize(true, 2, 3), 0);
});

/**
 * 输出速度：整轮平均（请求发出 → 响应结束），中间用估算、拿到真值后改用真值，
 * 样本太小时宁可不显示。
 *
 * 为什么不是「首个 delta 起算」：实测 KeyLights（anthropic-messages）把 700 字
 * 中文拆成 ~200 个 delta 全塞在 13–16ms 内推完，而响应实际耗时 7–9 秒。按首末
 * delta 计时，分母永远是十几毫秒，读数要么被门槛全部拦掉，要么是 19000 tok/s
 * 这种假数。provider 自己的 durationMs 是唯一诚实的分母。
 */

/** 一次响应：请求在 startedAt 发出，正文在 at 才回来。 */
const stream = (startedAt, at, text, actual = 0) =>
  speedDelta(speedBegin(startedAt), text, at, actual);

/** 分块流式：每块 100ms，模拟真实的多 delta 到达。 */
const streamChunks = (text, { startedAt = 0, firstAt = 500, chunk = 4, tokensActual = 0 } = {}) => {
  let tracker = speedBegin(startedAt);
  let at = firstAt;
  for (const piece of text.match(new RegExp(`[\\s\\S]{1,${chunk}}`, "g")) ?? []) {
    tracker = speedDelta(tracker, piece, at, tokensActual);
    at += 100;
  }
  return { tracker, at: at - 100 };
};

test("拉丁文按 4 字符一个 token 估算", () => {
  assert.equal(estimateTokens("abcd"), 1);
  assert.equal(estimateTokens("abcdefgh"), 2);
  assert.equal(estimateTokens(""), 0);
});

test("中文/假名/emoji 按全角算，一个字符一个 token", () => {
  assert.equal(estimateTokens("输出速度"), 4, "中文不能按 4 字符一 token 低估 4 倍");
  assert.equal(estimateTokens("tok/s 显示"), 1.5 + 2, "混合文本按宽窄分别计");
  assert.equal(estimateTokens("かな"), 2);
  assert.equal(estimateTokens("⚡"), 1);
  assert.equal(estimateTokens("🙂"), 1);
});

test("速度格式：恒定一位小数", () => {
  assert.equal(formatSpeed(42), "42.0 tok/s");
  assert.equal(formatSpeed(7.44), "7.4 tok/s");
  assert.equal(formatSpeed(0.04), "0.0 tok/s");
});

test("刚开流时没有读数：样本太小", () => {
  assert.equal(speedReading(speedBegin(0)), undefined, "还没开始就什么都不显示");
  // 8 个 token / 200ms，两个门槛都不过
  assert.equal(speedReading(stream(0, 200, "abcdefgh")), undefined);
});

test("分母是请求发出到现在的整段时间，不是首个 delta 之后", () => {
  // 请求 0ms 发出，正文 900ms 才回来（TTFT 很长），共 120 字符 = 30 token
  const reading = speedReading(stream(0, 1500, "a".repeat(120)));
  assert.ok(reading);
  assert.equal(reading.streaming, true);
  assert.equal(reading.tps, 20, "30 token / 1.5s（含 prefill），不是 30 token / 0.6s");
});

test("provider 一次性推完所有 delta 也不会算出离谱数字", () => {
  // 真实观测：~200 个 delta 全落在 14ms 内，整轮 6.8 秒、489 token
  let tracker = speedBegin(0);
  let at = 6800;
  for (let i = 0; i < 200; i++) {
    tracker = speedDelta(tracker, "", at, 0); // 同一毫秒内到达的 delta
  }
  tracker = speedEnd(tracker, 6781, 489);
  const reading = speedReading(tracker);
  assert.equal(reading.streaming, false);
  assert.equal(reading.tps, (489 * 1000) / 6781, "71.9 tok/s，而不是按 14ms 算出的 34928");
  assert.ok(reading.tps < 100, "真实量级");
});

test("拿到的真值更大时改用真值", () => {
  // 估算 30 token，provider 报 60：说明估算低了一半，以真值为准
  assert.equal(speedReading(stream(0, 1500, "a".repeat(120), 60)).tps, 40);
});

test("真值还没有（0）时不会被当成读数", () => {
  assert.equal(speedReading(stream(0, 1500, "a".repeat(120), 0)).tps, 20);
});

test("真值比估算小的时候保留估算，避免中途倒退", () => {
  // Anthropic 的 output_tokens 可能滞后于已流出的文本
  assert.equal(speedReading(stream(0, 1500, "a".repeat(120), 5)).tps, 20, "分子取较大者");
});

test("收尾用真值定稿", () => {
  let tracker = streamChunks("x".repeat(400), { chunk: 8 }).tracker; // 估算 100 token
  tracker = speedEnd(tracker, 3000, 240); // 真值 240
  const reading = speedReading(tracker);
  assert.equal(reading.streaming, false);
  assert.equal(reading.tps, (240 * 1000) / 3000, "收尾以 provider 的 output 为准");
});

test("收尾时 provider 没报 output 就保留估算", () => {
  let tracker = stream(0, 2000, "a".repeat(400)); // 100 token / 2s = 50
  tracker = speedEnd(tracker, 2000, 0);
  assert.equal(speedReading(tracker).tps, 50);
});

test("分母为零或分子为零时不显示", () => {
  const sameTick = speedDelta(speedBegin(5000), "a".repeat(400), 5000, 0);
  assert.equal(speedReading(sameTick), undefined, "请求和响应同一毫秒");
  assert.equal(speedReading(speedEnd(speedBegin(0), 5000, 0)), undefined, "一个 delta 都没有");
});

test("新响应开始后旧读数保留到首个 delta 到来", () => {
  const finished = speedEnd(stream(0, 2000, "a".repeat(400)), 2000, 100);
  assert.equal(finished.phase, "done", "message_start 只是记下请求时间，tracker 本身不动");
  // 下一轮 10s 才发出请求，首个 delta 12s 才到
  const next = speedDelta(speedBegin(10_000), "b", 12_000, 0);
  assert.equal(next.startedAt, 10_000, "新响应的计时从它自己的请求时间起算");
  assert.equal(speedReading(next), undefined, "新样本太小，读数先消失");
});

test("一个 delta 都没吐就 abort 的响应不产生读数", () => {
  // 插件在 awaitingFirstDelta 时直接 return，否则会拿上一轮的样本配这一轮的结束时间。
  const done = speedEnd(stream(0, 2000, "a".repeat(400)), 2000, 100);
  assert.equal(speedReading(done).tps, 50);
  assert.equal(speedReading(speedEnd(done, 12_000, 0)).tps, (100 * 1000) / 12_000, "这就是被拦下的错误读数");
});
