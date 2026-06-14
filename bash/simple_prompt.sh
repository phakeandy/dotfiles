_update_bash_prompt() {
    local job_str=""
    local job_count=$(jobs -p | wc -l)
    if [ $job_count -gt 0 ]; then
        job_str="[${job_count}] "
    fi

    local green='\[\033[01;32m\]'
    local blue='\[\033[01;34m\]'
    local red='\[\033[01;31m\]'
    local reset='\[\033[00m\]'
    local purple='\[\033[38;5;62m\]'

    PS1="${title}${debian_chroot:+($debian_chroot)}${green}${job_str}${reset}${purple}\$${reset} "
}

PROMPT_COMMAND="_update_bash_prompt"
