#!/bin/bash

function _code_open_wrapper {
  # 没有参数时直接调用原始code命令
  if [ $# -eq 0 ]; then
    code
    exit 0
  fi

  local full_path=$(realpath "$1")
  local distro_name=${WSL_DISTRO_NAME:-FedoraLinux-42}

  # 检查第一个参数是否是目录
  if [ -d "$1" ]; then
    code --folder-uri "vscode-remote://wsl+${distro_name}${full_path}"
  else
    code --file-uri "vscode-remote://wsl+${distro_name}${full_path}"
    code "$@"
  fi
}


alias code=_code_open_wrapper