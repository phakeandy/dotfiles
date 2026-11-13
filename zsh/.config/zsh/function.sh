ffd() {
    local target
    target=$(find ~/dotfiles -type f | fzf)
    if [[ -n "$target" ]]; then
        $EDITOR "$target"
    fi
}

ffw() {
    local target
    target=$(ls ~/workspace/ | fzf | xargs -I{} realpath ~/workspace/{})
    echo "$target"
    cd "$target"
}

a() {
    pi --provider deepseek --model deepseek-flash \
       --thinking high \
       --tui-mode fullscreen "$@"
}

# wt：选一棵 worktree 并 cd 过去。脚本只打印路径，cd 由这里做。
wt() {
    local d
    d=$(command wt "$@") || return
    if [ -d "$d" ]; then
        cd "$d" || return
    elif [[ -n "$d" ]]; then
        print -r -- "$d"
    fi
}
