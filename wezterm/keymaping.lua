local wezterm = require("wezterm")
local act = wezterm.action

local keys = {
	{
		key = "z",
		mods = "ALT",
		action = wezterm.action.ShowLauncher,
	},
	{
		key = "x",
		mods = "ALT",
		action = wezterm.action.ShowTabNavigator,
	},
	{
		key = "6",
		mods = "CTRL|SHIFT",
		action = require("wezterm").action.DisableDefaultAssignment,
	},
	{
		key = "_",
		mods = "CTRL|SHIFT",
		action = require("wezterm").action.DisableDefaultAssignment,
	},
	{ mods = "", key = "Home", action = wezterm.action({ SendString = "\001" }) },
	{ mods = "", key = "End", action = wezterm.action({ SendString = "\005" }) },
}

local mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

-- -- Winodws 模拟 tmux
-- local powershell_keys = {
--     { key = 'p', mods = 'CTRL', action = wezterm.action.ShowTabNavigator },
-- }

return {
	keys = keys,
	mouse_bindings = mouse_bindings,
	-- powershell_keys = powershell_keys,
}
