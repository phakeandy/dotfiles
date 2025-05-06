syntax on " 打开语法高亮
set showmode " 在底部显示，当前处于命令模式还是插入模式
set showcmd " 命令模式下，在底部显示，当前键入的指令
set mouse=a " 支持使用鼠标
set cursorline " 光标所在的当前行高亮
set number " Show current line number
set relativenumber " Show relative line numbers


set list listchars=tab:»\ ,trail:·,precedes:<,extends:> " set list 可以显示 listchars (see :help listchars)
set showbreak=↪\  " set wrap 后, line break 显示的图标

colorscheme retrobox
set background=dark


" ===========
" Key Mapping
" ===========


let mapleader = " "


nnoremap <C-s> :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>b :buffers<CR>:b
