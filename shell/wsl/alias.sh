# ALias for Wsl

# Usage: `foo | clip`
alias yank="iconv -f utf-8 -t GB18030 | clip.exe"
if [ -z "$ZSH_VERSION" ]; then
  # zsh 侧由 wsl/open.sh 里的 open 函数接管（explorer.exe）
  alias open="xdg-open"
fi
alias idea="/mnt/c/Program\ Files/JetBrains/IntelliJ\ IDEA\ Community\ Edition\ 2024.3.1.1/bin/idea64.exe"

# Convert Windows path to WSL path and handle the coding.
function _convert_win_path_to_wsl_path() {
  wslpath "$1" | iconv -f utf-8 -t GB18030 | sed 's/^/"/; s/$/"/' | clip.exe
}

# Usage: `pw2l "C:\Windows\Temp"`
alias pw2l=_convert_win_path_to_wsl_path
