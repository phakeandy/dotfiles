# Multiline prompt for both bash and zsh
# Using only ASCII characters with color support

source $(dirname "$(realpath "$0")")/pwd_fish_style.sh

# Bash configuration
if [ -n "$BASH_VERSION" ]; then
  if [ "$UID" -eq 0 ]; then
    # Root user prompt - only path is colored
    export PS1='\n\[\e[31m\]┌─[\u@\h]\[\e[0m\]-\[\e[31m\][\$(_fish_collapsed_pwd)]\[\e[0m\]\n\[\e[31m\]└─$ \[\e[0m\]'
  else
    # Regular user prompt - only path is colored
    export PS1='\n┌─[\u@\h]-\[\e[32m\][\$(_fish_collapsed_pwd)]\[\e[0m\]\n└─$ '
  fi
  
# Zsh configuration
else
  if [ "$UID" -eq 0 ]; then
    # Root user prompt - only path is colored
    export PROMPT=$'%F{red}┌─[%n@%m]%f-%F{red}[$(_fish_collapsed_pwd)]%f\n%F{red}└─$ %f'
  else
    # Regular user prompt - only path is colored
    export PROMPT=$'┌─[%n@%m]-%F{green}[$(_fish_collapsed_pwd)]%f\n└─$ '
  fi
fi
