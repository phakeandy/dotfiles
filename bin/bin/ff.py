#!/bin/bash

# The rg outputs are like:
#     models.py:15:class UserModel(
#     {1}       {2}{3}

function grep_fzf {
    rg --type python --line-number --color=never \
        $1 |
        fzf --preview-window nohidden \
        --preview 'bat --color=always --style=numbers --highlight-line {2} --line-range {2}:+30 {1}' \
        --delimiter=':' \
        --with-nth=3.. \
        --bind "ctrl-o:execute(vim +{2} {1} < /dev/tty > /dev/tty)"
}

case "$1" in
"c"|"class")
    grep_fzf 'class\s+\S+\s*\('  # class Foo(
    ;;
"f"|"func"|"fn"|"function"|"def")
    grep_fzf 'def\s+\S+\s*\('  # def foo(
    ;;
*)
    echo "usage: ff.py TYPE"
    echo "where TYPE := { class | func }"
    ;;
esac
