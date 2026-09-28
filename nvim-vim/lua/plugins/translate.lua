return {
  'skanehira/translate.vim',
  cmd = 'Translate',
  init = function()
    vim.g.translate_source = 'en'
    vim.g.translate_target = 'zh-CN'
    vim.g.translate_popup_window = 1
  end,
  keys = {
    { '<leader>tz', '<cmd>Translate<cr>', mode = { 'n', 'x' }, desc = 'Translate to Chinese' },
    { '<leader>te', '<cmd>Translate!<cr>', mode = { 'n', 'x' }, desc = 'Translate to English' },
  },
}
