ffw() {
    local target
    target=$(ls ~/workspace/ | fzy | xargs -I{} realpath ~/workspace/{})
    echo "$target"
    cd "$target"
}


ffd() {
    local target
    target=$(find ~/dotfiles -type f | fzy)
    if [[ -n "$target" ]]; then
        $EDITOR "$target"
    fi
}

