local wezterm = require("wezterm")

local config = wezterm.config_builder()

local launch_menu = {}
local default_prog = {}

-- 设置SHELL终端
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- windows下启用powershell
	local powershell_path = "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
	local pwsh_path = "C:/Program Files/PowerShell/7/pwsh.exe"
	--term = '' Set to empty so FZF works on windows
	table.insert(launch_menu, {
		label = "PowerShell",
		args = { pwsh_path, "-NoLogo" },
	})
	default_prog = { pwsh_path, "-NoLogo" }
end

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})

	-- 设置初始位置
	window:gui_window():set_position(200, 150)

	-- 默认窗口最大化
	-- window:gui_window():maximize()
end)

config.font = wezterm.font_with_fallback({ "CodeNewRoman Nerd Font Mono", "LXGW WenKai" }) --设置默认字体

config.font_size = 12

config.default_prog = default_prog

--- Tab Bar Config ---
config.use_fancy_tab_bar = false
config.tab_max_width = 50
config.show_tab_index_in_tab_bar = true
-- hide_tab_bar_if_only_one_tab = true
-- config.enable_tab_bar = false -- 关闭 tab_bar

config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 0,
}

-- 初始窗口大小
config.initial_rows = 40
config.initial_cols = 150
config.adjust_window_size_when_changing_font_size = false

config.window_background_opacity = 1.0   -- 背景不透明度

config.color_scheme = "Catppuccin Mocha" -- 设置主题
config.window_decorations = "RESIZE"
config.show_new_tab_button_in_tab_bar = false

config.hyperlink_rules = wezterm.default_hyperlink_rules()

wezterm.on("update-status", function(window)
	-- Grab the utf8 character for the "powerline" left facing
	-- solid arrow.
	-- local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	local LEFT_ARROW = utf8.char(0xe0b3)

	-- Grab the current window's configuration, and from it the
	-- palette (this is the combination of your chosen colour scheme
	-- including any overrides).
	local color_scheme = window:effective_config().resolved_palette
	local bg = color_scheme.background
	local fg = color_scheme.foreground

	window:set_right_status(wezterm.format({
		-- -- First, we draw the arrow...
		-- { Background = { Color = bg } },
		-- { Foreground = { Color = fg } },
		-- { Text = LEFT_ARROW },
		-- Then we draw our text
		-- { Background = { Color = bg } },
		-- { Foreground = { Color = fg } },
		-- { Text = " " .. wezterm.hostname() .. " " },
	}))
end)

-- 快捷键
config.keys = require("keymaping").keys

config.mouse_bindings = require("keymaping").mouse_bindings

-- config.enable_ssh_agent = false

return config

-- vim: ts=2 sts=2 sw=2 et
