#!/bin/bash

# Prompt loader - loads either single line or multiline prompt based on environment

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Default to single line prompt
PROMPT_TYPE="${PROMPT_TYPE:-singleline}"

# Function to toggle between single line and multiline prompts
prompt_toggle() {
  if [ "$PROMPT_TYPE" = "multiline" ]; then
    unset PROMPT_TYPE
    source "$SCRIPT_DIR/loader.sh"
    echo "Switched to single line prompt"
  else
    export PROMPT_TYPE=multiline
    source "$SCRIPT_DIR/loader.sh"
    echo "Switched to multiline prompt"
  fi
}

case "$PROMPT_TYPE" in
  multiline)
    if [ -f $SCRIPT_DIR/multiline.sh ]; then
      source $SCRIPT_DIR/multiline.sh
    else
      echo "Multiline prompt configuration not found"
    fi
    ;;
  *)
    if [ -f $SCRIPT_DIR/common.sh ]; then
      source $SCRIPT_DIR/common.sh
    else
      echo "Single line prompt configuration not found"
    fi
    ;;
esac