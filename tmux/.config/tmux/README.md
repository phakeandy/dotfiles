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

The tokyonight status line is a machine-local checkout at
`~/workspace/tmux-tokyonight` that is not part of this repo. When that path
exists the config runs it; otherwise it falls back to an inline Tokyo Night
style, so a fresh machine is themed without the checkout.

`fancy.conf.sh` is an alternative plugin-based config (tpm + catppuccin). tmux
does not read it; it is a reference copy, and it overrides the status line with
`set -g status-left ""` and friends, so do not run it on top of `tmux.conf`.
