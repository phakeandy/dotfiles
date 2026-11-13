# Tmux Config Usage

The active config is `tmux.conf` in this directory. tmux 3.x reads
`$XDG_CONFIG_HOME/tmux/tmux.conf`, which is `~/.config/tmux/tmux.conf` when
`XDG_CONFIG_HOME` is unset, and this directory is a stow symlink into the
dotfiles repo:

    cd ~/dotfiles && stow tmux

A tmux server reads the config only once, when the server starts, so after
editing it either restart the server (`tmux kill-server`) or reload it:

    tmux source-file ~/.config/tmux/tmux.conf   # or prefix + r

## Plugins

`tmux.conf` expects tpm plus the plugins declared with `@plugin`, all under
`~/.tmux/plugins`. `install-plugins.sh` clones them and reloads the config:

    bash ~/.config/tmux/install-plugins.sh

`prefix + I` (tpm install) still works on its own on a machine with network.

## Theme

Colours are Catppuccin and live in `themes/<flavour>.conf`, one palette file
per flavour (currently `latte` and `mocha`). Each file holds style options only;
the formats (`status-left`, `window-status-format`, lengths) stay in
`tmux.conf`, so adding a flavour means copying a file and changing hex values.

Switching is one command, and it is the same one tmux's `prefix + T` menu runs:

    theme mocha
    theme            # show the current flavour and the available ones

The script is `bin/bin/theme`. It writes the flavour to
`~/.config/theme/flavour` (read by neovim), points `~/.tmux/theme.conf` at the
palette, and reloads the running server, since tmux reads its config only once.
`tmux.conf` sources `~/.tmux/theme.conf` and falls back to `themes/latte.conf`
when the link does not exist yet.

The terminal emulator is not touched; ghostty already switches itself with
`theme = light:Catppuccin Latte,dark:Catppuccin Mocha`, and the script's names
are chosen to match that pair.

`fancy.conf.sh` is an alternative plugin-based config (tpm + catppuccin/tmux).
tmux does not read it; it is a reference copy, and both the plugin's status
formats and its `set -g status-left ""` would fight the palettes above, so do
not run it on top of `tmux.conf`.
