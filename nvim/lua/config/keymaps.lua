-- vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set({ 'n', 'v' }, '<C-s>', '<cmd>w<CR>')
vim.keymap.set({ 'n', 'v' }, 'ss', '<cmd>w<CR>')

vim.keymap.set({ 'i', 't', 'c'}, 'jk', '<esc>')

vim.keymap.set({ 'n', 'v' }, '<leader>d', '"+d', { desc = 'Delete to system clipboard' })
vim.keymap.set({ 'n', 'v' }, 'y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('n', 'Y', '"+Y', { desc = 'Yank line to system clipboard' })
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set({'n', 'v'}, 's', '<Nop>', { silent = true })

-- 在可视模式下粘贴时不覆盖剪切板
-- vim.keymap.set("x", "p", 'p:let @+=@0<CR>', { silent = true })

vim.keymap.set('n', '<space>x', ":.lua<CR>")
vim.keymap.set('v', '<space>x', ":lua<CR>")

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-j>', '<C-w>j')
vim.keymap.set({ 'n' }, '<A-k>', '<C-w>k')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')


vim.cmd('packadd! nohlsearch')
vim.cmd('packadd! matchit')
