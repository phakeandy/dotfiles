# If not running interactively, don't do anything.
#
# Here is normal scenario:
#            Interactive                Non-interactive
# Login      e.g. ssh / tty login       e.g. Rarely use
# Non-login  e.g. Login                 e.g. bash -c 'foo'
#
# Interactive Login shell will load ~/.profile and Interactive Non-login shell
# will load ~/.bashrc by default.
case $- in
    *i*) ;;
      *) return;;
esac

# History Settings
# In Bash, history usally refer to the history list in memory for each shell
# session. When a shell exits, the history list is saved to a file.
HISTSIZE=10000                 # Set command history in current shell sessions.
HISTFILESIZE=20000             # Set ~/.bash_history maximum lines.

HISTCONTROL=ignoredups         # Remove duplicate history entries.
shopt -s histappend            # Append to the history file, don't overwrite it.

# Check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize
# shopt -s lithist
shopt -s globstar              # ** for recursive search


[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Colorful Command.
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
# Colored GCC warnings and errors.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Alias
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit -v'
alias gcm='git commit -v'
alias gco='git checkout'
alias gdf='git diff -w'
alias glg='git log --oneline --graph'
alias gss='git status -s'
alias gst='git status'

alias ..='cd ..'


if [[ -x "$(command -v nvim)" ]]; then
	export EDITOR="nvim"
	export MANPAGER="nvim +Man!"
fi


# If lesspipe is available, enable it.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

## Source Other File
[ -f ~/.bash_aliases ] && . ~/.bash_aliases 
[ -f $HOME/dotfiles/bash/prompt.sh ] && . $HOME/dotfiles/bash/prompt.sh

# Source bash-completion file.
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
