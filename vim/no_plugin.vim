syntax on " 打开语法高亮
set showmode " 在底部显示，当前处于命令模式还是插入模式
set showcmd " 命令模式下，在底部显示，当前键入的指令
set mouse=a " 支持使用鼠标
set cursorline " 光标所在的当前行高亮
set number " Show current line number
set relativenumber " Show relative line numbers

" change the cursor between Normal and Insert modes in Vim
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[2 q"
augroup END

set list listchars=tab:»\ ,trail:·,precedes:<,extends:> " set list 可以显示 listchars (see :help listchars)
set showbreak=↪\  " set wrap 后, line break 显示的图标

colorscheme retrobox
set background=dark

" ===========
" Key Mapping
" ===========

let mapleader = " "

nnoremap <C-s> :w<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>b :buffers<CR>:b

nnoremap <leader>y "+y
vnoremap <leader>y "+y

" WSL
let g:clipboard = {
          \   'name': 'win32yank-wsl',
          \   'copy': {
          \      '+': 'win32yank.exe -i --crlf',
          \      '*': 'win32yank.exe -i --crlf',
          \    },
          \   'paste': {
          \      '+': 'win32yank.exe -o --lf',
          \      '*': 'win32yank.exe -o --lf',
          \   },
          \   'cache_enabled': 0,
          \ }

