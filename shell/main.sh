SCRIPT_DIR=$(dirname "$(realpath "$0")") # Get realpath for current file 

[[ -f "${SCRIPT_DIR}/prompt/common.sh" ]] $$ source "${SCRIPT_DIR}/prompt/common.sh"

[[ -f "${SCRIPT_DIR}/alias/git.sh" ]] $$ source "${SCRIPT_DIR}/alias/git.sh"
