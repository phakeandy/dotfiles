/**
 * thinking-step — alt+, / alt+. 逐级提高/降低 thinking level
 *
 * pi 内置只有 `app.thinking.cycle`（shift+tab）做循环，没有单向步进，
 * 所以这里用 shortcut 注册两个方向键。电平顺序就是 pi 自己的顺序，
 * 越界时停在两端；模型不支持的档位由 setThinkingLevel 自己夹取。
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const;
type Level = (typeof LEVELS)[number];

function step(pi: ExtensionAPI, direction: 1 | -1): void {
	const current = pi.getThinkingLevel();
	const index = LEVELS.indexOf(current as Level);
	const next = LEVELS[Math.min(LEVELS.length - 1, Math.max(0, (index < 0 ? 0 : index) + direction))];
	if (next === current) return;
	pi.setThinkingLevel(next);
}

export default function thinkingStep(pi: ExtensionAPI) {
	pi.registerShortcut("alt+,", {
		description: "Raise thinking level",
		handler: () => step(pi, 1),
	});
	pi.registerShortcut("alt+.", {
		description: "Lower thinking level",
		handler: () => step(pi, -1),
	});
}
