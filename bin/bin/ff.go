#!/bin/bash

# The rg outputs are like:
#     group.go:248:type groupReference struct {
#     {1}      {2} {3}

function grep_fzf {
    rg --type go --line-number --color=never \
        $1 |
        fzf --preview-window nohidden \
        --preview 'bat --color=always --style=numbers --highlight-line {2} --line-range {2}:+30 {1}' \
        --delimiter=':' \
        --with-nth=3.. \
        --bind "ctrl-o:execute(vim +{2} {1} < /dev/tty > /dev/tty)"
}

case "$1" in
"s"|"struct")
    grep_fzf 'type\s+\w+\s+struct\s*\{'  # type foo struct {
    ;;
"f"|"func"|"fn"|"function")
    grep_fzf 'func\s+\w+\s*\('  # func foo(
    ;;
"i"|"interface")
    grep_fzf 'type\s+\w+\s+interface\s*\{'  # type foo interface {
    ;;
*)
    echo "usage: ff.go TYPE"
    echo "where TYPE := { struct | func | interface }"
    ;;
esac
