# Git Alias for zsh

function _print_git_alias() { 
  alias | grep 'git' \
    | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/" \
    | sed "s/['|\']//g" \
    | sort \
    | { [[ -n $1 ]] && command grep -i -- "$1" || cat; }
  }

alias galias=_print_git_alias

### Aliases ###

# status
alias gst='git status'
compdef _git gst=git-status
alias gss='git status -s'
compdef _git gss=git-status

# diff
gdv() { git diff -w "$@" | view - }
compdef _git gdv=git-diff

# commit
alias gc='git commit -v'
compdef _git gc=git-commit
alias gcm='git commit -v'
compdef _git gcm=git-commit
alias gcma='git commit -v -a'
compdef _git gca=git-commit

# checkout
alias gco='git checkout'
compdef _git gco=git-checkout

# brach
alias gb='git branch'
compdef _git gb=git-branch
alias gba='git branch -a'
compdef _git gba=git-branch
alias gbd='git branch -d'
compdef _git gbd=git-branch

# log
alias glg='git log --oneline --graph'
alias glgs='git log --stat --max-count=5'
compdef _git glg=git-log
alias glgg='git log --graph --max-count=5'
compdef _git glgg=git-log

# add
alias ga='git add'
compdef _git ga=git-add
alias gaa='git add --all'

# pull
alias gp='git fetch -p && git merge --ff-only @{u}'
