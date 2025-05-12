# The entrance of shell config
# Compatible with bash and zsh

SCRIPT_DIR=$(dirname "$(realpath "$0")") # Get realpath for current file

if [ -n "$BASH_VERSION" ]; then
  # Bash
else
  # Zsh
  [[ -f "${SCRIPT_DIR}/zshrc/common.sh" ]] && source "${SCRIPT_DIR}/zshrc/common.sh"
  [[ -f "${SCRIPT_DIR}/alias/git.sh" ]] && source "${SCRIPT_DIR}/alias/git.sh"
fi

[[ -f "${SCRIPT_DIR}/prompt/common.sh" ]] && source "${SCRIPT_DIR}/prompt/common.sh"
