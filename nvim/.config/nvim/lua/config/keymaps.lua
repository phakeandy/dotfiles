-- vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set({ "n", "v" }, "<C-s>", "<cmd>w<CR>")
-- vim.keymap.set({ "n", "v" }, "ss", "<cmd>w<CR>")

vim.keymap.set({ "i", "c" }, "jk", "<esc>")

vim.keymap.set("n", "c", [["_c]])
vim.keymap.set("n", "Y", "y$")

vim.keymap.set({ "n", "v" }, "s", "<Nop>", { silent = true })

-- Use <Esc> to exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "jk", [[<C-\><C-n>]], { noremap = true, silent = true })

vim.keymap.set("n", "<Esc><Esc>", "<cmd>bd<cr>")

vim.keymap.set("n", "<leader>x", ":terminal bash -ic ")

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
-- vim.keymap.set({ "t", "i" }, "<A-h>", "<C-\\><C-n><C-w>h")
-- vim.keymap.set({ "t", "i" }, "<A-j>", "<C-\\><C-n><C-w>j")
-- vim.keymap.set({ "t", "i" }, "<A-k>", "<C-\\><C-n><C-w>k")
-- vim.keymap.set({ "t", "i" }, "<A-l>", "<C-\\><C-n><C-w>l")
-- vim.keymap.set({ "n" }, "<A-h>", "<C-w>h")
-- vim.keymap.set({ "n" }, "<A-j>", "<C-w>j")
-- vim.keymap.set({ "n" }, "<A-k>", "<C-w>k")
-- vim.keymap.set({ "n" }, "<A-l>", "<C-w>l")
--
vim.keymap.set("n", "<C-H>", "<C-w>h", { desc = "Focus on left window" })
vim.keymap.set("n", "<C-J>", "<C-w>j", { desc = "Focus on below window" })
vim.keymap.set("n", "<C-K>", "<C-w>k", { desc = "Focus on above window" })
vim.keymap.set("n", "<C-L>", "<C-w>l", { desc = "Focus on right window" })

-- Window resize (respecting `v:count`)
vim.keymap.set(
	"n",
	"<C-Left>",
	'"<Cmd>vertical resize -" . v:count1 . "<CR>"',
	{ expr = true, replace_keycodes = false, desc = "Decrease window width" }
)
vim.keymap.set(
	"n",
	"<C-Down>",
	'"<Cmd>resize -"          . v:count1 . "<CR>"',
	{ expr = true, replace_keycodes = false, desc = "Decrease window height" }
)
vim.keymap.set(
	"n",
	"<C-Up>",
	'"<Cmd>resize +"          . v:count1 . "<CR>"',
	{ expr = true, replace_keycodes = false, desc = "Increase window height" }
)
vim.keymap.set(
	"n",
	"<C-Right>",
	'"<Cmd>vertical resize +" . v:count1 . "<CR>"',
	{ expr = true, replace_keycodes = false, desc = "Increase window width" }
)

vim.keymap.set("n", [[\w]], "<Cmd>setlocal wrap! wrap?<CR>", { desc = "Toggle wrap" })
vim.keymap.set("n", [[\s]], "<Cmd>setlocal spell!<CR>", { desc = "Toggle spell" })
vim.keymap.set("n", [[\C]], "<Cmd>setlocal cursorcolumn! cursorcolumn?<CR>", { desc = "Toggle cursorcolumn" })
vim.keymap.set("n", [[\c]], "<Cmd>setlocal cursorline! cursorline?<CR>", { desc = "Toggle cursorline" })
vim.keymap.set("n", [[\r]], "<Cmd>setlocal relativenumber! relativenumber?<CR>", { desc = "Toggle relativenumbe" })
vim.keymap.set("n", [[\i]], function()
	local is_enabled = vim.lsp.inlay_hint.is_enabled()
	vim.lsp.inlay_hint.enable(not is_enabled)
end)

vim.cmd("packadd! nohlsearch")
vim.cmd("packadd! matchit")
