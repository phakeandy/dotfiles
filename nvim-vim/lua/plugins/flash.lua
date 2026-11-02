return {
	'folke/flash.nvim',
	event = 'VeryLazy',
	opts = {
		-- 不做全屏遮罩/全文高亮，视线只跟着 label 走
		highlight = { backdrop = false, matches = false },
	},
	keys = {
		-- 原生 flash：纯 ASCII / 正则跳转（s 让给 flash-zh 的中文跳转）
		{ '<leader>F', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash jump' },
		-- 跨窗口 remote
		{ 'r', mode = 'o', function() require('flash').remote() end, desc = 'Flash remote' },
		-- 在 / 搜索时手动切换 flash
		{ '<c-s>', mode = 'c', function() require('flash').toggle() end, desc = 'Toggle Flash search' },
	},
}
