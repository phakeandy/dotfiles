#!/bin/bash

# The rg outputs are like:
#     group.go:248:type groupReference struct {
#     {1}      {2} {3}

case "$1" in
    "s"|"struct")
        rg --type go --line-number --color=never \
            'type\s+\w+\s+struct\s*\{' | # type foo struct {
            fzf --preview-window nohidden \
            --preview 'bat --color=always --style=numbers --highlight-line {2} --line-range {2}:+30 {1}' \
            --delimiter=':' \
            --with-nth=3.. \
            --bind "ctrl-o:execute(vim +{2} {1} < /dev/tty > /dev/tty)"
        ;;
    *)
        echo "usage: f.go TYPE"
        echo "where TYPE := { struct | func }"
        ;;
esac
