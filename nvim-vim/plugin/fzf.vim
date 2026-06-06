lua << EOF
vim.pack.add({
  'https://github.com/junegunn/fzf.vim',
})
EOF
runtime! /home/phakeandy/.nix-profile/bin/fzf

noremap <leader>f <cmd>Files<cr>
noremap <leader>sf :Files!\ 
noremap <leader>, <cmd>Buffers<cr>

let $FZF_DEFAULT_COMMAND = 'rg --files '
      \ . "--glob '!node_modules' "
      \ . "--glob '!target' "
      \ . "--glob '!dist' "
      \ . "--glob '!.venv' "
      \ . "--glob '!*.pyc' "
      \ . "--glob '!__pycache__' "

let $FZF_DEFAULT_OPTS = '--layout=reverse --color=pointer:12'
