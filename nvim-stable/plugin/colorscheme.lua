local colors = {
  bg = '#000000',
  fg = '#ffffff',
  string = '#50c878',
  comment = '#ff9b21',
}

local highlights = {
  Normal = { fg = colors.fg, bg = colors.bg },
  String = { fg = colors.string },
  Comment = { fg = colors.comment },
  Identifier = { link = 'Normal' },
  Function = { link = 'Normal' },
  Statement = { link = 'Normal' },
  Constant = { link = 'Normal' },
  Special = { link = 'Normal' },

  StatusLine = { bg = 'None' },

  ['@variable'] = { link = 'Normal' },
}

vim.cmd('highlight clear')
for group, attrs in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, attrs)
end
