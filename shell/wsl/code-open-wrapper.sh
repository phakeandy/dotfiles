function code {
  # 没有参数时直接调用原生命令
  if [ $# -eq 0 ]; then
    command code
    return $?
  fi

  local distro_name=${WSL_DISTRO_NAME:-FedoraLinux-42}
  local args=()
  local convert_done=false

  # 遍历所有参数
  for arg in "$@"; do
    # 如果尚未转换且参数是存在的文件/目录
    if ! $convert_done && [ -e "$arg" ]; then
      convert_done=true
      local full_path=$(realpath "$arg")
      if [ -d "$arg" ]; then
        args+=(--folder-uri "vscode-remote://wsl+${distro_name}${full_path}")
      else
        args+=(--file-uri "vscode-remote://wsl+${distro_name}${full_path}")
      fi
    else
      # 其他参数直接传递
      args+=("$arg")
    fi
  done

  # 调用 VS Code
  command code "${args[@]}"
}

# 保持原有的别名和补全设置
if [ -n "$ZSH_VERSION" ]; then
  compdef code=code
fi
