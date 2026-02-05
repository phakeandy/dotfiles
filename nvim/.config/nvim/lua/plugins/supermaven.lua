vim.pack.add({ "https://github.com/supermaven-inc/supermaven-nvim" })

require("supermaven-nvim").setup({
	keymaps = {
		accept_suggestion = "<Tab>",
		clear_suggestion = "<C-]>",
		accept_word = "<C-Right>",
	},
	-- ignore_filetypes = { "cpp" },
	log_level = "info",
	disable_keymaps = false, -- disables built in keymaps for more manual control
	condition = function()
		return false
	end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
})
