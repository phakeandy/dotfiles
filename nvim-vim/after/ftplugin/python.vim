setlocal formatprg=uvx\ ruff\ format\ -\ --stdin-filename\ %
setlocal formatexpr=

nnoremap <buffer> <localleader>sc <cmd>Rg class \S+\(<cr>
nnoremap <buffer> <localleader>sf <cmd>Rg def \S+\(<cr>
nnoremap <buffer> <F5> <cmd>terminal python3 %<cr>
