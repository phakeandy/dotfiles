" navigation 不切断当前 undo/change
inoremap <C-b> <C-G>U<Left>
inoremap <C-f> <C-G>U<Right>
inoremap <C-a> <C-G>U<Home>
inoremap <C-e> <C-G>U<End>

inoremap <Left>  <C-G>U<Left>
inoremap <Right> <C-G>U<Right>
inoremap <Up>    <C-G>U<Up>
inoremap <Down>  <C-G>U<Down>

" 不知道为什么不起作用
inoremap <M-b> <c-o>b
inoremap <M-f> <c-o>w

inoremap <C-k> <C-O>D
cnoremap <C-k> <C-O>D

inoremap <C-v> <C-G>u<C-R>+
cnoremap <C-v> <C-r>+
" nnoremap <c-v> "+p

" Select mode: -- (insert) SELECT --
set keymodel+=startsel
set selectmode+=key

snoremap <C-C> <C-O>"+y
snoremap <C-X> <C-O>"+d

vnoremap <C-C> <C-O>"+y
vnoremap <C-X> <C-O>"+d

