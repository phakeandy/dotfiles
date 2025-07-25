#!/bin/bash

# Prompt loader - loads either single line or multiline prompt based on environment

# Default to single line prompt
PROMPT_TYPE="${PROMPT_TYPE:-singleline}"

# Function to toggle between single line and multiline prompts
prompt_toggle() {
  if [ "$PROMPT_TYPE" = "multiline" ]; then
    unset PROMPT_TYPE
    source "$SCRIPT_DIR/prompt/loader.sh"
    echo "Switched to single line prompt"
  else
    export PROMPT_TYPE=multiline
    source "$SCRIPT_DIR/prompt/loader.sh"
    echo "Switched to multiline prompt"
  fi
}

case "$PROMPT_TYPE" in
  multiline)
    if [ -f $SCRIPT_DIR/prompt/multiline.sh ]; then
      source $SCRIPT_DIR/prompt/multiline.sh
    else
      echo "Multiline prompt configuration not found"
    fi
    ;;
  *)
    if [ -f $SCRIPT_DIR/prompt/common.sh ]; then
      source $SCRIPT_DIR/prompt/common.sh
    else
      echo "Single line prompt configuration not found"
    fi
    ;;
esac