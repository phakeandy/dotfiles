# 1. 基础环境准备 (Git 提示符)
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    . /usr/lib/git-core/git-sh-prompt
fi

export PROMPT_DIRTRIM=3
export GIT_PS1_SHOWDIRTYSTATE=true

_update_bash_prompt() {
    local job_str=""
    [[ $(jobs -p | wc -l) -gt 0 ]] && job_str="*"

    local git_info=""
    if type __git_ps1 &>/dev/null; then
        git_info=$(__git_ps1 " (%s)")
    fi

    local green='\[\033[01;32m\]'
    local blue='\[\033[01;34m\]'
    local red='\[\033[01;31m\]'
    local reset='\[\033[00m\]'
    local title='\[\e]0;\u: \w\a\]'

    # 标题 + chroot + 作业符号 + 用户名(绿) + 冒号 + 路径(蓝) + Git(红) + 提示符
    PS1="${title}${debian_chroot:+($debian_chroot)}${job_str}${green}\u${reset}:${blue}\w${reset}${red}${git_info}${reset}\$ "
}

PROMPT_COMMAND="_update_bash_prompt"
