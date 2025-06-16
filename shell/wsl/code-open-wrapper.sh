#!/bin/bash

# 没有参数时直接调用原始code命令
if [ $# -eq 0 ]; then
    code
    exit 0
fi

# 检查第一个参数是否是目录
if [ -d "$1" ]; then
    # 获取文件夹的绝对路径
    folder_full_path=$(realpath "$1")
    # 使用WSL_DISTRO_NAME环境变量获取发行版名称
    distro_name=${WSL_DISTRO_NAME:-FedoraLinux-42}
    # 执行VS Code命令
    code --folder-uri "vscode-remote://wsl+${distro_name}${folder_full_path}"
else
    # 如果参数不是目录，直接调用原始code命令
    code "$@"
fi
