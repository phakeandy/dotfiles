# 效果展示
# [1] ~/dotfiles main *+ $
#
# 基础环境准备 (Git 提示符)
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
fi

export PROMPT_DIRTRIM=2
export GIT_PS1_SHOWDIRTYSTATE=true

_update_bash_prompt() {
    local job_str=""
    local job_count=$(jobs -p | wc -l)
    if [ $job_count -gt 0 ]; then
        job_str="[${job_count}] "
    fi

    local git_info=""
    if type __git_ps1 &>/dev/null; then
        git_info=$(__git_ps1 " %s")
    fi

    local green='\[\033[01;32m\]'
    local blue='\[\033[01;34m\]'
    local red='\[\033[01;31m\]'
    local reset='\[\033[00m\]'
    local title='\[\e]0;\u: \w\a\]'

    PS1="${title}${debian_chroot:+($debian_chroot)}${green}${job_str}${reset}${blue}\W${reset}${red}${git_info}${reset} \$ "
}

PROMPT_COMMAND="_update_bash_prompt"
