local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Appearance
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.initial_rows = 40
config.initial_cols = 80
-- config.window_background_opacity = 0.95 -- 背景不透明度
config.color_scheme = 'Tomorrow Night Bright (Gogh)'

-- Wait https://github.com/wezterm/wezterm/pull/4093/ merge
-- local original = wezterm.color.get_builtin_schemes()["Tomorrow Night Bright (Gogh)"]
-- local custom = wezterm.color.get_builtin_schemes()["Tomorrow Night Bright (Gogh)"]
-- custom.selection_bg = original.selection_fg
-- custom.selection_fg = original.selection_bg
-- config.color_schemes = {
--   ["Custom"] = custom,
-- }
-- config.color_scheme = "Custom"
config.force_reverse_video_cursor = true

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
-- config.font = wezterm.font_with_fallback({ "CodeNewRoman Nerd Font Mono" }) --设置默认字体
config.font = wezterm.font_with_fallback({ "Sarasa Mono SC" }) --设置默认字体
config.font_size = 12
config.adjust_window_size_when_changing_font_size = false

-- Other
config.hyperlink_rules = wezterm.default_hyperlink_rules()
-- config.default_prog = wezterm.target_triple == "x86_64-pc-windows-msvc" and { "wsl.exe", "~" } or nil

config.default_domain = "WSL:Debian"

-- Keymapping
config.keys = {
	{ key = "6", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "_", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b\r" }) },
}
config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "CTRL", action = wezterm.action.OpenLinkAtMouseCursor },

	-- Disable the default copy on selection
	-- See https://github.com/wezterm/wezterm/discussions/3760
	{ event = { Up = { streak = 1, button = "Left" } }, mods = "NONE", action = wezterm.action.Nop },
}

-- config.leader = { key = "s", mods = "CTRL" }

-- Apply wez-tmux plugin with optional configuration
-- require("plugins.wez-tmux.plugin").apply_to_config(config, {
-- 	-- Optional: Customize tab index base (0-based or 1-based)
-- 	-- tab_and_split_indices_are_zero_based = true
-- })

return config
