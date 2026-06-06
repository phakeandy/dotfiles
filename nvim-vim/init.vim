let mapleader = " "
let maplocalleader = "\\"

nnoremap c "_c
nnoremap - <Cmd>Oil<CR>
tnoremap <Esc> <C-\><C-n>

command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis

function! CopyVisualRangeToClipboard()
  let start_line = line("'<")
  let end_line   = line("'>")
  normal! \<Esc>
  let file_path = expand("%:p")
  let text = file_path . ":" . start_line . "-" . end_line
  let @+ = text
endfunction

vnoremap <silent> <leader>y :call CopyVisualRangeToClipboard()<CR>

set number relativenumber
set clipboard=unnamedplus
let g:clipboard = 'win32yank'
set ignorecase
set foldmethod=indent foldlevel=99
set cursorline
set cmdheight=0 laststatus=3 statusline=
set wrap
set exrc
set splitright splitbelow
set smarttab smartindent
set formatoptions+=Mm " include the chinese charactor
set list listchars=tab:\»\ ,trail:·,nbsp:␣,precedes:<,extends:>

lua << EOF
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
  signs = false,
  underline = { severity = { min = vim.diagnostic.severity.ERROR } },
})
EOF

lua require('vim._core.ui2').enable()

packadd! nohlsearch
packadd! matchit
packadd! cfilter

augroup YankHighlight
  autocmd!
  autocmd TextYankPost * lua vim.hl.on_yank({ higroup = 'Visual', timeout = 300 })
augroup END

" 禁用 netrw
let g:loaded_netrwPlugin = 1
let g:loaded_netrw = 1
