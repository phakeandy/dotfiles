# The entrance of shell config
# Compatible with bash and zsh

set +x 

source_if_exists() {
  # $1 是传递给函数的第一个参数，即文件路径
  if [[ -f "$1" ]]; then
    source "$1"
    return 0
  else
    echo "Warning: File not found, skipping source: $1" >&2
    return 1
  fi
}

SCRIPT_DIR=$(dirname "$(realpath "$0")") # Get realpath for current file

if [ -n "$BASH_VERSION" ]; then
  # Bash
else
  # Zsh
  source_if_exists "${SCRIPT_DIR}/zshrc/common.sh"
  source_if_exists "${SCRIPT_DIR}/alias/git.sh"
fi

source_if_exists "${SCRIPT_DIR}/prompt/loader.sh"
source_if_exists "${SCRIPT_DIR}/alias/docker.sh"

# WSL
if [[ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]]; then
  for file in ${SCRIPT_DIR}/wsl/*.sh; do
    source_if_exists "$file"
  done
fi

# API key
source_if_exists "$HOME/.apikey"

unset -f source_if_exists