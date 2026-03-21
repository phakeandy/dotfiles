vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

-- require("nvim-treesitter").install({
-- 	"html",
-- 	"css",
-- 	"javascript",
-- 	"zig",
-- 	"rust",
-- 	"python",
-- 	"lua",
-- 	"typescript",
-- })
--
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		-- 检查当前文件是否有 treesitter parser，有就开启 treesitter
		local ok, _ = pcall(vim.treesitter.get_parser, bufnr)
		if ok then
			-- syntax highlighting, provided by Neovim
			vim.treesitter.start()
			vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo[0][0].foldmethod = "expr"

			-- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
