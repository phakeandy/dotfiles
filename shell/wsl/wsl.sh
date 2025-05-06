# ALias for Wsl

# Usage: `foo | clip`
alias clip="iconv -f utf-8 -t GB18030 | clip.exe"

# Functions for wsl

# Convert Windows path to WSL path
# And handle the coding.
# Usage: `wp "C:\Windows\Temp"`
function wp() {
  wslpath "$1" | iconv -f utf-8 -t GB18030 | sed 's/^/"/; s/$/"/' | clip.exe
}
