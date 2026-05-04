if vim.g.neovide then
  vim.g.neovide_theme = 'dark'
  vim.o.guifont = 'Sarasa Mono SC:h14'
  vim.o.background = 'dark'

  local map = vim.keymap.set
  map({ 'i', 'c' }, '<C-S-V>', '<C-R>+', { noremap = true })
  map('n', '<C-S-V>', '"+p', { noremap = true })

  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set('n', '<C-=>', function() change_scale_factor(1.25) end)
  vim.keymap.set('n', '<C-->', function() change_scale_factor(1 / 1.25) end)

  vim.pack.add(
    { 'https://github.com/sevenc-nanashi/neov-ime.nvim' },
    { confirm = false }
  )
end
