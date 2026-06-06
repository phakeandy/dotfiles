local lsp_servers = {
	lua_ls = {
		Lua = { workspace = { library = vim.api.nvim_get_runtime_file("lua", true) } },
	},
	clangd = {},
	rust_analyzer = {},
	gopls = {},
	vtsls = {},
	-- pylsp = {},
	basedpyright = {},
	-- pyright = {},
}

vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig", -- default configs for lsps
	"https://github.com/mason-org/mason.nvim", -- package manager
}, { confirm = false })

require("mason").setup()

for server, config in pairs(lsp_servers) do
	vim.lsp.config(server, { settings = config })
	vim.lsp.enable(server)
end
