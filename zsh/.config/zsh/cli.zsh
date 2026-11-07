# zoxide
export _ZO_ECHO=1 # print pwd when cd succussful
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# yazi
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
}

# 容器内 docker 操作宿主机
if [[ -e /run/.containerenv ]] && command -v distrobox-host-exec >/dev/null; then
    docker() { distrobox-host-exec docker "$@" }
fi
