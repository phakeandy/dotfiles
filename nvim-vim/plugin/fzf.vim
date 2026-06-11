lua << EOF
vim.pack.add({
  'https://github.com/junegunn/fzf.vim',
})
EOF
runtime! /home/phakeandy/.nix-profile/bin/fzf

noremap <leader>f <cmd>Files<cr>
noremap <localleader>f <cmd>BFiles<cr>
noremap <leader>, <cmd>Buffers<cr>
let opt = { 'window': 'call FloatingFZF()' }

command! -bang BFiles call fzf#vim#files(expand('%:p:~:h'), opt, <bang>0)
command! -bang Buffers call fzf#vim#buffers(opt, <bang>0)

let $FZF_DEFAULT_COMMAND = 'rg --files '
      \ . "--glob '!node_modules' "
      \ . "--glob '!target' "
      \ . "--glob '!dist' "
      \ . "--glob '!.venv' "
      \ . "--glob '!*.pyc' "
      \ . "--glob '!__pycache__' "
let $FZF_DEFAULT_OPTS = '--layout=reverse --color=pointer:12'

let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }
let g:fzf_vim = {} " Initialize configuration dictionary

let g:fzf_vim.paste_key = 'alt-p'
let g:fzf_vim.preview_window = ['hidden,right,40%', 'ctrl-/']


function! FloatingFZF()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  let height = float2nr(10)
  let width = float2nr(80)
  let horizontal = float2nr((&columns - width) / 2)
  let vertical = 1

  let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height,
        \ 'style': 'minimal'
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction

