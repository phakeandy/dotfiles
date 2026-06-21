local colors = {
  bg = '#000000',
  fg = '#c6c6c6',
  string = '#50c878',
  -- comment = '#5fafff',
  comment = '#9b9ea4',
  keyword = '#91b1f1',
  -- keyword = '#f5a97f',
}

local highlights = {
  Normal = { fg = colors.fg, bg = colors.bg },
  String = { fg = colors.string },
  Comment = { fg = colors.comment },
  Identifier = { link = 'Normal' },
  Function = { link = 'Normal' },
  Statement = { fg = colors.keyword },
  Constant = { link = 'Normal' },
  Special = { link = 'Normal' },

  StatusLine = { bg = 'None' },
  MatchParen = { fg = '#ff00af' },

  ['@variable'] = { link = 'Normal' },
}

vim.cmd('highlight clear')
for group, attrs in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, attrs)
end
