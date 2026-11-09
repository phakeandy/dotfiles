-- 小鹤双拼小工具：<leader>zh 查键位表，<leader>zs 输入全拼 → 自动转双拼 → flash 跳转
local function xiaohe_jump()
	vim.ui.input({ prompt = '全拼（空格分隔）: ' }, function(input)
		if not input or input == '' then return end
		local ok, xiaohe = pcall(require, 'flash_zh_simple.xiaohe')
		if not ok then
			vim.notify('flash-zh-simple 未加载', vim.log.levels.WARN)
			return
		end
		local code = xiaohe.to_xiaohe(input)
		-- 直接用转换好的双拼码开跳；不用插件自带的 :XiaoheSimpleSearch，它会 print 一下把 flash 打断
		require('flash').jump({
			pattern = code,
			search = { mode = require('flash-zh').zh_mode },
		})
	end)
end

return {
	'AQchance/flash-zh-simple.nvim',
	event = 'VeryLazy',
	dependencies = { 'folke/flash.nvim', 'rainzm/flash-zh.nvim' },
	config = function()
		-- 插件默认的 <leader>xs / <leader>xh 和 init.vim 里的 <leader>x（terminal）前缀撞车，换成 z 前缀
		for _, lhs in ipairs({ '<leader>xs', '<leader>xh' }) do
			pcall(vim.keymap.del, 'n', lhs)
		end
		vim.keymap.set('n', '<leader>zh', '<cmd>XiaoheHelp<cr>', { desc = '小鹤双拼键位表' })
		vim.keymap.set('n', '<leader>zs', xiaohe_jump, { desc = '全拼 → 小鹤双拼 → flash 跳转' })
	end,
}
