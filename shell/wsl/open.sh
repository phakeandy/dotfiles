# WSL 下的 `open`：交给 Windows 资源管理器打开
# 只在 zsh 里定义（bash 侧继续用 alias.sh 里的 xdg-open）

if [ -n "$ZSH_VERSION" ]; then
  unalias open 2>/dev/null # 先摘掉 alias，否则 alias 先参与解析，函数定义会报 parse error

  # Usage: open [file|dir ...]   无参数时打开当前目录
  function open() {
    local arg win_path
    local -a targets win_paths

    if (( $# == 0 )); then
      targets=(.)
    else
      targets=("$@")
    fi

    for arg in "${targets[@]}"; do
      if [[ ! -e "$arg" ]]; then
        print -u2 "open: 没有这个文件或目录: $arg"
        return 1
      fi
      win_path=$(wslpath -w -- "$(realpath -- "$arg")") || return 1
      win_paths+=("$win_path")
    done

    explorer.exe "${win_paths[@]}"
    return 0 # explorer.exe 正常打开也常返回 1，这里不当成失败
  }
fi
