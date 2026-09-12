setlocal formatprg=uvx\ ruff\ format\ -\ --stdin-filename\ %
setlocal formatexpr=

nnoremap <buffer> <localleader>r <cmd>terminal ++curwin python3 %<cr>
