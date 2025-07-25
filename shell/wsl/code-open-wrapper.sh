#!/bin/bash

# 没有参数时直接调用原始code命令
if [ $# -eq 0 ]; then
  code
  exit 0
fi

full_path=$(realpath "$1")
distro_name=${WSL_DISTRO_NAME:-FedoraLinux-42}

# 检查第一个参数是否是目录
if [ -d "$1" ]; then
  code --folder-uri "vscode-remote://wsl+${distro_name}${full_path}"
else
  code --file-uri "vscode-remote://wsl+${distro_name}${full_path}"
  code "$@"
fi

alias code="$(dirname $(readlink -f "$0"))/$0"