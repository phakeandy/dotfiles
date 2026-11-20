-- tabby.nvim：把 Neovim 的 tabpage 当工作区用（替代 tmux window 的那一层）。
--
-- 只做三件事：选 preset、按需显示、把操作绑到键上。渲染全交给插件自己的
-- `active_wins_at_tail` preset —— 左边 tab，右边当前 tab 的窗口；标签名用
-- 插件默认的 fallback（当前窗口文件名 + `[n+]` 窗口数），配色用插件默认的
-- TabLine/TabLineSel 那套高亮组，所以跟 colorscheme 天然一致。
--
-- 想换布局只改 preset 一行：
--   active_wins_at_tail / active_wins_at_end / tab_with_top_win /
--   active_tab_with_wins / tab_only
-- 想看每行画的是什么：~/.local/share/nvim/lazy/tabby.nvim/lua/tabby/presets.lua

--- 跳到第 n 个 tab；不存在就什么也不做（`:tabnext 9` 在只有 2 个 tab 时是 E16）。
---@param n number
local function goto_tab(n)
  if n <= vim.fn.tabpagenr('$') then
    vim.cmd('tabnext ' .. n)
  end
end

local keys = {
  { '<leader>tn', '<cmd>tabnew<cr>', desc = 'New tab' },
  { '<leader>tx', '<cmd>tabclose<cr>', desc = 'Close tab' },
  { '<leader>to', '<cmd>tabonly<cr>', desc = 'Close other tabs' },
  { '<leader>tj', '<cmd>Tabby jump_to_tab<cr>', desc = 'Jump to tab' },
  { '<leader>tp', '<cmd>Tabby pick_window<cr>', desc = 'Pick window' },
  {
    '<leader>tr',
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
    -- 1 = 只有一个 tab 时不画 tabline（Neovim 默认值，也是 tmux 的观感：
    -- 没有第二个 window 就不占那一行）。写出来是因为 tabby 的 README 建议设 2，
    -- 以后想常显就改回 2。
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
