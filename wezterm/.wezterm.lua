local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Appearance
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.color_scheme = 'zenburn (terminal.sexy)'

config.window_decorations = "RESIZE"

-- Tab
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 50

-- Font
config.font = wezterm.font_with_fallback({ "Iosevka Nerd Font Mono", "Noto Sans CJK SC" })
config.font_size = 12
config.adjust_window_size_when_changing_font_size = false

-- On Windows
-- config.default_domain = "WSL:Debian"

-- Keymapping
config.keys = {
	{ key = "6", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "_", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
}
config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = wezterm.action.OpenLinkAtMouseCursor },
}

return config
