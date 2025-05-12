#!/bin/bash
set -e

# 检测当前 Shell 类型
if [ -n "${ZSH_VERSION-}" ]; then
  CONFIG_FILE=~/.zshrc
elif [ -n "${BASH_VERSION-}" ]; then
  CONFIG_FILE=~/.bashrc
else
  echo "错误：此脚本仅支持在 bash 或 zsh 中运行。" >&2
  exit 1
fi

# 获取 main.sh 的绝对路径
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
MAIN_SH_PATH="$SCRIPT_DIR/main.sh"

# 检查 main.sh 是否存在
if [ ! -f "$MAIN_SH_PATH" ]; then
  echo "错误：main.sh 未在 $MAIN_SH_PATH 找到" >&2
  exit 1
fi

# 构造 source 行
SOURCE_LINE="source \"$MAIN_SH_PATH\""

# 创建配置文件（如果不存在）
if [ ! -f "$CONFIG_FILE" ]; then
  touch "$CONFIG_FILE"
  echo "已创建空的配置文件 $CONFIG_FILE"
fi

# 检查是否已存在该 source 行
if ! grep -qF -- "$SOURCE_LINE" "$CONFIG_FILE" 2>/dev/null; then
  echo "$SOURCE_LINE" >>"$CONFIG_FILE"
  echo "成功将 source 命令添加到 $CONFIG_FILE"
else
  echo "$CONFIG_FILE 中已存在 source 命令，无需重复添加"
fi
