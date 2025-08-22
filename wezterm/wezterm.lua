local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Appearance
config.window_padding = { left = 10, right = 10, top = 10, bottom = 0 }
config.initial_rows = 40
config.initial_cols = 150
-- config.window_background_opacity = 1.0 -- 背景不透明度
config.color_scheme = "Catppuccin Mocha" -- 设置主题
config.window_decorations = "RESIZE"
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():set_position(200, 150) -- 设置初始位置
end)

-- Tab
config.show_new_tab_button_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 50
config.show_tab_index_in_tab_bar = true
-- config.enable_tab_bar = false -- 关闭 tab_bar

-- Font
config.font = wezterm.font_with_fallback({ "CodeNewRoman Nerd Font Mono", "LXGW WenKai" }) --设置默认字体
config.font_size = 12
config.adjust_window_size_when_changing_font_size = false

-- Other
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.default_prog = wezterm.target_triple == "x86_64-pc-windows-msvc" and { "wsl.exe", "~" } or nil

-- Keymapping
config.keys = {
	{ key = "z", mods = "ALT", action = wezterm.action.ShowLauncher },
	{ key = "a", mods = "CTRL|SHIFT", action = wezterm.action.ShowTabNavigator },
	{ key = "6", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "_", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ mods = "", key = "Home", action = wezterm.action({ SendString = "\001" }) },
	{ mods = "", key = "End", action = wezterm.action({ SendString = "\005" }) },
}
config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = wezterm.action.OpenLinkAtMouseCursor },
}

return config
