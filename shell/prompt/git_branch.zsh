#!/usr/sbin/env zsh

autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '%b '
setopt prompt_subst
precmd_functions+=( vcs_info )

fish_style_pwd() {
  local p=${${PWD:/~/\~}/#~\//\~/}
  psvar[1]="${(@j[/]M)${(@s[/]M)p##*/}##(.|)?}$p:t"
}
precmd_functions+=( fish_style_pwd )

export PROMPT='%(1j.*.)%f%n %F{blue}%1v%f %F{red}${vcs_info_msg_0_}%f%(!.#.$) '
export RPROMPT='%(?..%F{160}%?%f)'
