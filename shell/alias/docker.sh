# Show all alias related docker

function _print_docker_alias() {
  alias | grep 'docker' |
    sed "s/^\([^=]*\)=\(.*\)/\1 => \2/" |
    sed "s/['|\']//g" |
    sort |
    { [[ -n $1 ]] && command grep -i -- "$1" || cat; }
}

alias dal=_print_docker_alias

function _docker_exec_fn {
  docker exec -it $1 ${2:-bash}
}

function _docker_print_container_fn {
  for ID in $(docker ps | awk '{print $1}' | grep -v 'CONTAINER'); do
    docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
  done
}

alias d="docker"
alias dps="docker ps"
alias dex=_docker_exec_fn
alias dl="docker logs -f"
alias dname=_docker_print_container_fn

alias dc="docker compose"
alias dcu="docker compose up -d"
alias dcd="docker compose down"
