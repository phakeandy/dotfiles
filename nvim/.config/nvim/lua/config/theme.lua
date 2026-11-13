-- Which theme the rest of the machine is on.
--
-- ~/bin/theme writes the Catppuccin flavour name to ~/.config/theme/flavour;
-- this module reads it and applies the matching colorscheme. A file instead of
-- an environment variable, because a running neovim has to be able to change
-- theme too (bin/theme pokes every --listen server), and env vars are frozen at
-- process start.
local M = {}

local state = vim.fn.expand('~/.config/theme/flavour')

-- Only latte is light. catppuccin derives its highlight groups from
-- 'background' but installs no autocmd for it, so the flavour is applied
-- explicitly below and 'background' is only kept in sync for other plugins.
local is_light = { latte = true }

local function read_flavour()
    local ok, lines = pcall(vim.fn.readfile, state)
    local name = ok and lines[1] and vim.trim(lines[1]) or ''
    return name ~= '' and name or nil
end

local function known(flavour)
    local ok, catppuccin = pcall(require, 'catppuccin')
    return ok and catppuccin.flavours[flavour] ~= nil
end

--- Apply ~/.config/theme/flavour. Missing or unknown names fall back to latte,
--- matching the tmux fallback in tmux.conf.
function M.apply()
    local flavour = read_flavour()
    if not flavour or not known(flavour) then
        flavour = 'latte'
    end

    vim.o.background = is_light[flavour] and 'light' or 'dark'
    vim.g.theme_flavour = flavour
    vim.cmd.colorscheme('catppuccin-' .. flavour)
end

return M
