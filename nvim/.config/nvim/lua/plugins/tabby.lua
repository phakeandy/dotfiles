---@param n number
local function goto_tab(n)
  if n <= vim.fn.tabpagenr('$') then vim.cmd('tabnext ' .. n) end
end

local keys = {
  {
    '<C-w>c',
    function()
      vim.cmd('tabnew')
      vim.cmd('terminal')
      vim.cmd('startinsert')
    end,
    desc = 'New tab',
  },
  -- 这两个看上去用处不是很大
  { '<leader>tj', '<cmd>Tabby jump_to_tab<cr>', desc = 'Jump to tab' },
  { '<leader>tp', '<cmd>Tabby pick_window<cr>', desc = 'Pick window' },
  {
    '<C-w>,',
    function()
      local name = vim.fn.input('Tab name: ')
      if name == '' then return end
      -- 走 feature API 而不是 :Tabby rename_tab，后者按空格切参数，
      -- 名字里带空格会被截断。
      require('tabby.feature.tab_name').set(0, name)
    end,
    desc = 'Rename tab',
  },
  -- GUI 手感：Ctrl+Tab 切工作区。Neovim 本身没有这两个默认键位。
  { '<C-Tab>', '<cmd>tabnext<cr>', mode = 'n', desc = 'Next tab' },
  { '<C-S-Tab>', '<cmd>tabprevious<cr>', mode = 'n', desc = 'Previous tab' },
  { '<C-Tab>', '<C-o><cmd>tabnext<cr>', mode = 'i', desc = 'Next tab' },
  { '<C-S-Tab>', '<C-o><cmd>tabprevious<cr>', mode = 'i', desc = 'Previous tab' },
}

-- <leader>1 … <leader>9：按 tabline 上显示的数字跳过去。
-- 只占 leader 后面的数字，`3j` 这种 count 完全不受影响。
for i = 1, 9 do
  keys[#keys + 1] = {
    '<leader>' .. i,
    function() goto_tab(i) end,
    desc = 'Go to tab ' .. i,
  }
end

return {
  'nanozuki/tabby.nvim',
  lazy = false,
  dependencies = { 'nvim-mini/mini.icons' },
  init = function()
    -- 1 = 只有一个 tab 时不画 tabline
    vim.o.showtabline = 1
  end,
  ---@type TabbyConfig
  opts = {
    preset = 'active_wins_at_tail',
    option = {
      nerdfont = true,
      theme = {
        fill = 'TabLineFill',
        head = 'TabLine',
        current_tab = 'TabLineSel',
        tab = 'TabLine',
        win = 'TabLine',
        tail = 'TabLine',
      },
    },
  },
  keys = keys,
}
