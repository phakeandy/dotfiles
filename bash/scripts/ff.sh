ffw() {
    local target
    target=$(ls ~/workspace/ | fzf | xargs -I{} realpath ~/workspace/{})
    echo "$target"
    cd "$target"
}


ffd() {
    local target
    target=$(find ~/dotfiles -type f | fzf)
    if [[ -n "$target" ]]; then
        $EDITOR "$target"
    fi
}

