-- tabby.nvim：把 Neovim 的 tabpage 当工作区用（替代 tmux window 的那一层）。
--
-- 只做三件事：选 preset、打开常显、把操作绑到键上。渲染全交给插件自己的
-- `active_wins_at_tail` preset —— 左边 tab，右边当前 tab 的窗口；标签名用
-- 插件默认的 fallback（当前窗口文件名 + `[n+]` 窗口数），配色用插件默认的
-- TabLine/TabLineSel 那套高亮组，所以跟 colorscheme 天然一致。
--
-- 想换布局只改 preset 一行：
--   active_wins_at_tail / active_wins_at_end / tab_with_top_win /
--   active_tab_with_wins / tab_only
-- 想看每行画的是什么：~/.local/share/nvim/lazy/tabby.nvim/lua/tabby/presets.lua
return {
  'nanozuki/tabby.nvim',
  lazy = false,
  dependencies = { 'nvim-mini/mini.icons' },
  init = function()
    -- 默认只在 >=2 个 tab 时显示；工作区栏要一直在，像 tmux 的 status line。
    vim.o.showtabline = 2
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
  keys = {
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
  },
}
