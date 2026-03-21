set number relativenumber
set list listchars=tab:»\ ,trail:·,nbsp:␣,precedes:<,extends:>
set wrap showbreak=↪\
set splitbelow
set ignorecase smartcase
set visualbell				" 删除烦人的铃声
set hidden				" 允许在有未保存更改的情况下切换到其他缓冲区
set hlsearch				" 高亮搜索结果

set background=dark
colorscheme lunaperche

set directory=~/.vim/swap//

set clipboard=unnamedplus
" WSL clipboard config
autocmd TextYankPost * call system('win32yank.exe -i --crlf', @")
function! Paste(mode)
	let @" = system('win32yank.exe -o --lf')
	return a:mode
endfunction
map <expr> p Paste('p')
map <expr> P Paste('P')
nnoremap c "_c
nnoremap Y y$

set path+=** wildignore+=*/node_modules/*,*/.git/*,*/.svn/*


runtime! defaults.vim
runtime! ftplugin/man.vim " :Man
packadd! matchit
packadd! nohlsearch
packadd! hlyank
packadd! editorconfig
packadd! editexisting

inoremap jk <esc>
nnoremap <esc><esc> <cmd>bd<cr>
tnoremap <silent> jk <C-\><C-n>

" In vim, use esc to map <m-x>
nnoremap <esc>h <C-w>h
nnoremap <esc>j <C-w>j
nnoremap <esc>k <C-w>k
nnoremap <esc>l <C-w>l

let g:mapleader = ' '

" nnoremap <leader>e <cmd>Ex<cr>

call plug#begin()
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'morhetz/gruvbox'

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'

Plug 'tpope/vim-vinegar'
call plug#end()

nnoremap <leader>, <cmd>Buffers<cr>
nnoremap <leader>f <cmd>Files<cr>
nnoremap <leader><leader> <cmd>FZF<cr>
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'

let g:netrw_banner = 0 " Hide the banner
