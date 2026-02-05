vim.pack.add({
	{ src = "https://github.com/echasnovski/mini.nvim", name = "mini.nvim" },
})

require("mini.icons").setup()

require("mini.statusline").setup()
require("mini.pairs").setup()

-- require("mini.files").setup({
--   mappings = {
--     go_in_plus = "<CR>",
--     close = "<Esc><Esc>",
--   },
-- })
--
-- vim.keymap.set("n", "<leader>e", require("mini.files").open, { desc = "打开文件浏览器" })
