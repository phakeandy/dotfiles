#!/usr/bin/env bash
#
# Install the tmux plugins that tmux.conf expects.
#
#     bash ~/.config/tmux/install-plugins.sh
#
# ~/.config/tmux is a stow symlink into the dotfiles repo, so this script lives
# with the config it serves and never lands in $HOME. Re-running is safe:
# existing checkouts are left alone.
#
# A tmux server reads the config only once, when the server starts, so the
# script reloads it at the end when it is invoked from inside tmux.

set -euo pipefail

plugin_dir="$HOME/.tmux/plugins"
mkdir -p "$plugin_dir"

clone() {
    url="$1"
    dir="$2"
    if [ -d "$dir/.git" ]; then
        echo "have    $dir"
    else
        echo "cloning $url"
        git clone --depth 1 "$url" "$dir"
    fi
}

# tmux.conf runs ~/.tmux/plugins/tpm/tpm, so tpm has to be there first.
clone https://github.com/tmux-plugins/tpm "$plugin_dir/tpm"

# The plugins declared with @plugin in tmux.conf. Cloning them up front leaves
# nothing for the "prefix + I" install step to fetch.
clone https://github.com/Morantron/tmux-fingers "$plugin_dir/tmux-fingers"
clone https://github.com/tmux-plugins/tmux-prefix-highlight "$plugin_dir/tmux-prefix-highlight"
clone https://github.com/sainnhe/tmux-fzf "$plugin_dir/tmux-fzf"

if [ -n "$(printenv TMUX)" ]; then
    tmux source-file "$HOME/.config/tmux/tmux.conf"
    echo "reloaded ~/.config/tmux/tmux.conf"
else
    echo "now start tmux and press prefix + I to let tpm finish"
fi
