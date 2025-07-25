# Single line prompt for both bash and zsh

source $(dirname "$(realpath "$0")")/pwd_fish_style.sh

if [ -n "$BASH_VERSION" ]; then
  if [ "$UID" -eq 0 ]; then
    export PS1='\u@\h \[\e[31m\]$(_fish_collapsed_pwd)\[\e[0m\]# '
  else
    export PS1='\u@\h \[\e[32m\]$(_fish_collapsed_pwd)\[\e[0m\]$ '
  fi
else
  if [ $UID -eq 0 ]; then
    export PROMPT='%(1j.*.)%f%n@%m %F{1}$(_fish_collapsed_pwd)%f # '
  else
    export PROMPT='%(1j.*.)%f%n@%m %F{2}$(_fish_collapsed_pwd)%f $ '
  fi
fi
