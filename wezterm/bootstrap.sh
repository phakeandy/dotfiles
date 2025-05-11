#!/bin/bash
if [[ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]]; then
  # In WSL
  WINDOWS_WEZTERM_CONFIG="/mnt/c/Users/lenovo/.config/wezterm/"
  CURRENT_DIR=$(dirname "${BASH_SOURCE[0]}")
  cp $CURRENT_DIR/* $WINDOWS_WEZTERM_CONFIG
fi
