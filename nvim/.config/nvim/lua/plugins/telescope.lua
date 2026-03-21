vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" }, -- needs run `cd /home/phakeandy/.local/share/nvim/site/pack/core/opt/telescope-fzf-native.nvim/ && make`
})

require("telescope").setup({
	defaults = {},
	pickers = {
		-- buffers = {
		-- 	initial_mode = "normal",
		-- },
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"

			-- the default case_mode is "smart_case"
		},
	},
})
require("telescope").load_extension("ui-select")
require("telescope").load_extension("fzf")

vim.keymap.set("n", "<leader><leader>", require("telescope.builtin").find_files, { desc = "Telescope find files" })

vim.keymap.set("n", "sc", function()
	require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Telescope find neovim configuraition files" })

vim.keymap.set("n", "<leader>/", require("telescope.builtin").live_grep, { desc = "Telescope live grep" })

vim.keymap.set("n", "<leader>,", require("telescope.builtin").buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "S", "<cmd>Telescope<cr>", { desc = "Telescope" })
-- vim.keymap.set("ca", "ls", function()
--   require("telescope.builtin").buffers(require("telescope.themes").get_ivy({}))
-- end, { desc = "Telescope buffers" })
--
-- vim.keymap.set("n", "sh", require("telescope.builtin").help_tags, { desc = "Telescope help tags" })
