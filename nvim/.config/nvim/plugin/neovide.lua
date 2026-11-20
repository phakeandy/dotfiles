-- Neovide 专属设置（终端里跑 nvim 时整个文件不生效）。
--
-- 原则：只加,不改。所有键位都避开了 Neovim 的默认功能：
--   Ctrl+Shift+V  粘贴 —— Ctrl+V 仍是 Neovim 的 verbatim insert
--   Ctrl+= / Ctrl+- / Ctrl+0  字号 —— 这三个组合 Neovim 默认未占用
-- 剪贴板本来就有 clipboard=unnamedplus 和 plugin/chinese.vim，这里只是把
-- GUI 里肌肉记忆最深的那个键补上，作为冗余而非替代。
if not vim.g.neovide then return end

-- 窗口外观跟着 ~/.config/theme/flavour，免得 mocha 工作区上挂一个浅色窗框。
-- （KDE 用服务端装饰，这一项只在支持 CSD 的 Wayland 桌面上有效。）
vim.g.neovide_theme = vim.g.theme_flavour == 'latte' and 'light' or 'dark'

-- 字体：拉丁字母用和终端一致的 Iosevka，中文和图标由 Maple Mono NF CN 兜底。
-- 缩放只改 :h 后面的字号，不动窗口布局（scale_factor 那种整体放大会连
-- 边距一起缩放，字号缩放才是编辑器的手感）。
local FONTS = 'Iosevka Nerd Font Mono,Maple Mono NF CN'
local DEFAULT_SIZE = 15
local font_size = DEFAULT_SIZE

local function apply_font() vim.o.guifont = ('%s:h%s'):format(FONTS, font_size) end

apply_font()

local map = vim.keymap.set
local gui_modes = { 'n', 'i', 'v', 't' }

local function zoom(delta)
  font_size = math.max(8, math.min(40, font_size + delta))
  apply_font()
end

map(gui_modes, '<C-=>', function() zoom(1) end, { desc = 'Font size +1' })
map(gui_modes, '<C-+>', function() zoom(1) end, { desc = 'Font size +1' })
map(gui_modes, '<C-->', function() zoom(-1) end, { desc = 'Font size -1' })
map(gui_modes, '<C-0>', function()
  font_size = DEFAULT_SIZE
  apply_font()
end, { desc = 'Font size reset' })

-- GUI 里的粘贴：插入/命令行用 Ctrl+R +，普通/可视用 "+p。
-- 复制不用管：clipboard=unnamedplus 已经把 y 同步到系统剪贴板了。
map(
  { 'i', 'c', 't' },
  '<C-S-V>',
  '<C-r>+',
  { noremap = true, desc = 'Paste clipboard' }
)
map({ 'n', 'v' }, '<C-S-V>', '"+p', { noremap = true, desc = 'Paste clipboard' })

vim.o.title = true
