#            Interactive                Non-interactive
# Login      e.g. ssh, tty login        e.g. rarely used
# Non-login  e.g. terminal emulator     e.g. zsh -c 'command', scripts
#
# Interactive login: .zshenv -> .zprofile -> .zshrc -> .zlogin
# Interactive non-login: .zshenv → .zshrc
# Non-interactive: only .zshenv (unless -i flag given)


bindkey -e  # emacs keybinding
bindkey '\e[1;5C' forward-word   # ctrl + ->
bindkey '\e[1;5D' backward-word  # ctrl + <-

bindkey '\e[A' history-beginning-search-backward # <Up>
bindkey '\e[B' history-beginning-search-forward


# History Settings
HISTFILE=~/.zsh_history  # zsh has no built-in default value for HISTFILE, so we set explicitly.
HISTSIZE=10000  # the maximum number of history entries loaded into the shell's active memory during a session
SAVEHIST=10000  # the maximum number of lines written to history file (here is ~/.zsh_history)
setopt histignoredups  # Remove duplicate history entries

stty -ixon  # Disable Ctrl-S


# Autoload is a zsh built-in command that handle lazy loading function in $fpath. 
# `-U` is Unalias. `-z` is zsh style function formating.
autoload -Uz compinit
compinit -d ~/.cache/zcompdump  # enable zsh built-in completion system
zstyle ':compinstall' filename "$HOME/.zshrc"


autoload -Uz edit-command-line
zle -N edit-command-line  # turn shell functions into new widgets
bindkey '^x^e' edit-command-line


if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    # Colorful Manpage
    export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
    export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
    export LESS_TERMCAP_me=$(tput sgr0)
    export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
    export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
    export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
    export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
    export LESS_TERMCAP_mr=$(tput rev)
    export LESS_TERMCAP_mh=$(tput dim)
    export LESS_TERMCAP_ZN=$(tput ssubm)
    export LESS_TERMCAP_ZV=$(tput rsubm)
    export LESS_TERMCAP_ZO=$(tput ssupm)
    export LESS_TERMCAP_ZW=$(tput rsupm)
    export GROFF_NO_SGR=1         # For Konsole and Gnome-terminal

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi


# define prompt. like PROMPT_COMMAND in bash
precmd() {
    local job_count=${#jobstates}
    local job_str=""
    if (( job_count > 0 )); then
        job_str="[${job_count}] "
    fi

    PS1="%S${job_str}\$%s "
}

# Alias
alias gco='git checkout' && compdef _git gco=git-checkout
alias gb='git branch' && compdef _git gb=git-branch
alias gd='git diff' && compdef _git gd=git-diff
alias ga='git add' && compdef _git ga=git-add
alias gaa='git add --all' && compdef _git ga=git-add
alias gcm='git commit -v' && compdef _git gcm=git-commit
alias glg='git log --oneline --graph' && compdef _git glg=git-log
alias glgg='git log --oneline --graph -5' && compdef _git glgg=git-log
alias gss='git status -s' && compdef _git gss=git-status
alias gst='git status' && compdef _git gst=git-status
alias gls='git ls-files' && compdef _git gls=git-ls-files
alias wip="git commit -v -m wip"

#if command -v nvim >/dev/null 2>&1; then
#       export EDITOR="nvim"
#       export MANPAGER="nvim +Man!"
#fi

alias e="$EDITOR"

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
    export FZF_DEFAULT_OPTS="--height 70% --layout=reverse --color=pointer:12 \
                             --border=none --preview-window=border-none \
                             --preview='cat {}' --preview-window hidden \
                             --bind 'ctrl-/:toggle-preview'"
fi

if command -v yazi >/dev/null 2>&1; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        command rm -f -- "$tmp"
    }
fi

[ -f $HOME/.apikeys ] && source $HOME/.apikeys

export PATH=~/.local/bin:$PATH
export PATH=~/bin:$PATH
[ -d $HOME/go/bin ] && export PATH="$HOME/go/bin:$PATH"

ffw() {
    local target
    target=$(ls ~/workspace/ | fzf | xargs -I{} realpath ~/workspace/{})
    echo "$target"
    cd "$target"
}


ffd() {
    local target
    target=$(find ~/dotfiles -type f | fzf)
    if [[ -n "$target" ]]; then
        $EDITOR "$target"
    fi
}
