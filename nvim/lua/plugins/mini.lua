vim.pack.add {
  { src = 'https://github.com/echasnovski/mini.nvim', name = 'mini.nvim' },
}


require('mini.icons').setup()
require('mini.files').setup({
  mappings = {
    go_in_plus = '<CR>'
  }
})
vim.keymap.set('n', '<leader>e', MiniFiles.open)
