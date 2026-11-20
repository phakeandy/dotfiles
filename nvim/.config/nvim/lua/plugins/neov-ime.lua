-- Neovide 的 IME 预编辑 / 候选框渲染。
--
-- Neovide 把 IME 的 preedit 当成一段浮层自己画，这个插件把 preedit 与
-- commit 事件接到 Neovim 的 UI 上，中文在插入模式里才落点正确。
-- 只在 GUI 里加载：终端里（foot/ghostty + fcitx5）由终端自己处理 IME。
return {
  'sevenc-nanashi/neov-ime.nvim',
  cond = function()
    return vim.g.neovide ~= nil
  end,
  -- 插件自带 plugin/ 脚本，装上即生效，无需 setup。
}
