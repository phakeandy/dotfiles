import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	// Interactive tmux subagents also load global extensions.
	if (process.env.PI_SUBAGENT_ID) return;

	// agent_end can be followed by retries, compaction, or queued work.
	pi.on("agent_settled", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		try {
			const result = await pi.exec(
				"notify-send",
				["Pi", `任务已完成，等待你的输入。\n${ctx.cwd}`],
				{ timeout: 3000 },
			);
			if (result.code !== 0 || result.killed) {
				ctx.ui.notify("桌面通知发送失败，请检查 notify-send 和桌面通知服务。", "warning");
			}
		} catch {
			ctx.ui.notify("桌面通知发送失败，请检查 notify-send 和桌面通知服务。", "warning");
		}
	});
}
