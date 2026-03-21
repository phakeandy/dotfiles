vim.o.termguicolors = true
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", precedes = "<", extends = ">" }

vim.o.number = true
vim.o.relativenumber = true

vim.o.wrap = true
vim.o.showbreak = "↪ "

-- vim.o.expandtab = true
-- vim.o.shiftwidth = 4
-- vim.o.tabstop = 4
-- vim.o.softtabstop = 4

vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.path:append("**") -- set for :find
vim.o.wildignore = "*/node_modules/*,*/.git/*,*/.svn/*"
-- set wildoptions=pum

vim.o.winborder = "rounded"
vim.o.cursorline = true
vim.o.background = "dark"

-- vim.o.completeopt = "menuone" -- 即使只有一个匹配项，也显示补全菜单。
vim.diagnostic.config({ virtual_text = true })

-- disable netrw
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1

-- use system clipboard
vim.opt.clipboard = "unnamedplus"

vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

local chinese_punctuations = { "，", "。", "；", "：", "？", "！", "（", "）", "【", "】", "“", "”" }

for _, char in ipairs(chinese_punctuations) do
	vim.opt.iskeyword:remove(char)
end
