local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Platform
local is_windows = wezterm.target_triple:find("windows") ~= nil
local is_macos = wezterm.target_triple:find("darwin") ~= nil
local is_linux = not is_windows and not is_macos

-- Appearance
config.color_scheme = "Catppuccin Mocha"
config.window_decorations = "TITLE | RESIZE"
config.adjust_window_size_when_changing_font_size = false
config.hide_mouse_cursor_when_typing = true

if is_windows then
	config.window_padding = { left = 4, right = 4, top = 4, bottom = 4 }
else
	config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
end

-- Tab
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 50

-- Font
-- Windows 上是 Noto Sans SC，Linux 上可能是 Noto Sans CJK SC
config.font = wezterm.font_with_fallback({ "Iosevka Nerd Font Mono", "Noto Sans SC", "Noto Sans CJK SC" })
config.font_size = is_windows and 16 or 12
config.line_height = 0.9 -- ghostty: adjust-cell-height = -10%
-- 关掉连字
config.harfbuzz_features = { "calt=0", "liga=0", "dlig=0" }

config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.scrollback_lines = 10000

if is_windows then
	config.default_domain = "WSL:Debian"
end

-- Keymapping
config.keys = {
	-- ghostty: keybind = ctrl+shift+l=goto_split:previous
	-- { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Prev") },

	{ key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\r") },
	{ key = "6", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
	{ key = "_", mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },
}

config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = act.OpenLinkAtMouseCursor },
}

return config
