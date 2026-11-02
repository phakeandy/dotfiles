-- flash.nvim 的中文扩展：用小鹤双拼（或全拼的首字母）直接跳到中文字符
return {
	'rainzm/flash-zh.nvim',
	event = 'VeryLazy',
	dependencies = { 'folke/flash.nvim' },
	keys = {
		{
			's',
			mode = { 'n', 'x', 'o' },
			function() require('flash-zh').jump({ chinese_only = false }) end,
			desc = 'Flash 中文跳转（中英混杂）',
		},
		{
			'<leader>sz',
			mode = { 'n', 'x', 'o' },
			function() require('flash-zh').jump({ chinese_only = true }) end,
			desc = 'Flash 中文跳转（仅中文）',
		},
	},
	-- 想给标点加匹配，比如全角引号：
	-- config = function() require('flash-zh').setup({}) end,
}
