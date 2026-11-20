-- tabby.nvim：把 Neovim 的 tabpage 画成一条工作区标签栏。
--
-- 它只负责“画”，tabpage 本身还是 Neovim 原生的（:tabnew / gt / gT / g<Tab>），
-- 所以关掉这个插件，一切键位照旧 —— 这是用来替代 tmux window 的那一层：
-- 一个 tab 就是一个工作区（编辑器 + 侧边栏 + 终端 + lazygit），
-- 当前 tab 里的窗口列在右边，相当于 tmux 的 pane 一览。
--
-- 高亮不写死颜色：每次重绘都从当前 colorscheme 的 palette 里取，
-- 所以 ~/bin/theme 切换 latte/mocha 时这条 bar 会跟着变。
local function palette()
  local ok, p = pcall(function()
    return require('catppuccin.palettes').get_palette()
  end)
  return ok and p or nil
end

-- 只有 palette 用不了（比如换掉 catppuccin）时才用到这些兜底色。
local fallback = {
  bg = '#1e1e2e',
  fg = '#cdd6f4',
  dim = '#6c7086',
  accent = '#b4befe',
  warn = '#fab387',
}

local function colors()
  local p = palette()
  if not p then return fallback end
  return {
    bg = p.mantle,
    fg = p.text,
    dim = p.overlay1,
    accent = p.lavender,
    warn = p.peach,
    sel_bg = p.surface1,
    win_bg = p.surface0,
    crust = p.crust,
  }
end

-- 终端 buffer 是 term://<cwd>//<pid>，直接取尾段会显示成一堆数字，
-- 所以取 cwd 的 basename（也就是 tmux window 里最想看到的那样）。
local function tail_name(bufid)
  local name = vim.api.nvim_buf_get_name(bufid)
  if name == '' then return '' end
  if vim.bo[bufid].buftype == 'terminal' then
    local dir = name:gsub('^term://', ''):gsub('//%d+$', ''):gsub('//.*$', '')
    local base = vim.fn.fnamemodify(dir, ':t')
    return base ~= '' and base or 'term'
  end
  return vim.fn.fnamemodify(name, ':t')
end

local function win_label(win)
  local buf = win.buf()
  local name = tail_name(buf.id)
  if name ~= '' then return name end
  return buf.type() == 'terminal' and 'term' or '[No Name]'
end

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
    option = {
      tab_name = {
        -- 没手动改名时用 tab 里第一个窗口（左上角那个）的文件名，
        -- 而不是当前焦点窗口：切窗口时标签名不该跟着变。
        name_fallback = function(tabid)
          local wins = vim.api.nvim_tabpage_list_wins(tabid)
          if #wins == 0 then return '[No Name]' end
          return tail_name(vim.api.nvim_win_get_buf(wins[1]))
        end,
      },
      buf_name = {
        -- 窗口一览里只留文件名，路径交给 fzf / oil 去折腾。
        mode = 'tail',
      },
    },
    line = function(line)
      local c = colors()
      local fill = { bg = c.bg, fg = c.dim }
      local tab_hl = { bg = c.bg, fg = c.dim }
      local tab_cur_hl = { bg = c.sel_bg, fg = c.fg, bold = true }
      local win_hl = { bg = c.bg, fg = c.dim }
      local win_cur_hl = { bg = c.win_bg, fg = c.accent, bold = true }

      local function tab_changed(tab)
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab.id)) do
          if vim.bo[vim.api.nvim_win_get_buf(win)].modified then return true end
        end
        return false
      end

      return {
        { ' ', hl = fill },
        line.tabs().foreach(function(tab)
          local cur = tab.is_current()
          local hl = cur and tab_cur_hl or tab_hl
          local key = tab.in_jump_mode() and tab.jump_key() or tostring(tab.number())
          local name = tab.name()
          if name == '' then name = '[No Name]' end
          return {
            { ' ' .. key .. ' ', hl = { bg = hl.bg, fg = cur and c.accent or c.dim, bold = true } },
            { name:gsub('%%', '%%%%') .. ' ', hl = hl },
            { tab_changed(tab) and '●' or '', hl = { bg = hl.bg, fg = c.warn } },
            cur and tab.close_btn(' ×') or { "", hl = { bg = hl.bg } },
            { ' ', hl = fill },
            hl = fill,
          }
        end),
        line.spacer(),
        line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
          local cur = win.is_current()
          local hl = cur and win_cur_hl or win_hl
          return {
            { ' ' .. win_label(win) .. ' ', hl = hl },
            { ' ', hl = fill },
          }
        end),
        { ' ', hl = fill },
        hl = fill,
      }
    end,
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
        -- 走 feature API 而不是 :Tabby rename_tab，后者按空格切参数，名字里
        -- 带空格会被截断。
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
