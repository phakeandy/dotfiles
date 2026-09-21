let mapleader = " "
let maplocalleader = "\\"

nnoremap c "_c
nnoremap Y y$
noremap j gj
nnoremap k gk
"nnoremap <tab> <c-w><c-w><c-w>_
nnoremap <leader><leader> <c-w><c-w>
nnoremap <leader>b :ls<cr>:b<space>
augroup EscInTerm
  autocmd TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
  autocmd FileType fzf tunmap <buffer> <Esc>
augroup END

command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis

function! CopyVisualRangeToClipboard()
  let start_line = line("'<")
  let end_line   = line("'>")
  normal! \<Esc>
  let file_path = expand("%:p:~")
  let text = file_path . ":" . start_line . "-" . end_line
  let @+ = text
endfunction
vnoremap <silent> <leader>y :call CopyVisualRangeToClipboard()<CR>

set number relativenumber
set clipboard=unnamedplus
set linebreak breakindent
set grepprg=rg\ --vimgrep\ --no-heading
set path+=**
set wildignore+=*/node_modules/*,*/.git/*,*/.svn/*
lua << EOF
if vim.loop.os_uname().sysnam == "Windows" then
  vim.cmd [[let g:clipboard = 'win32yank']]
end
EOF
set ignorecase
set foldmethod=indent foldlevel=99
set cursorline
"set cmdheight=0 laststatus=3 statusline=
set noshowmode
set wrap
set exrc
set splitright splitbelow
set smarttab smartindent
set formatoptions+=Mm " include the chinese charactor
set list listchars=tab:\»\ ,trail:·,nbsp:␣,precedes:<,extends:>
set completeopt=longest,menuone,popup pumheight=6

lua << EOF
vim.diagnostic.config({
  --severity_sort = true,
  virtual_text = true,
  signs = false,
  --underline = { severity = { min = vim.diagnostic.severity.ERROR } },
})

vim.keymap.set('n', '<leader>ld', function()
  local filter = { bufnr = 0 }
  local enabled = not vim.diagnostic.is_enabled(filter)
  vim.diagnostic.enable(enabled, filter)
  vim.notify('Diagnostics ' .. (enabled and 'enabled' or 'disabled') .. ' for buffer')
end, { desc = 'Toggle diagnostics for buffer' })

vim.keymap.set('n', '<leader>lD', function()
  local enabled = not vim.diagnostic.is_enabled()
  vim.diagnostic.enable(enabled)
  vim.notify('Diagnostics ' .. (enabled and 'enabled' or 'disabled') .. ' globally')
end, { desc = 'Toggle diagnostics globally' })
EOF

"lua require('vim._core.ui2').enable()

packadd! nohlsearch
packadd! matchit
packadd! cfilter

" Build and quickfix workflow
nnoremap <leader>m <cmd>make<cr>
noremap <leader>c <cmd>cwindow<cr>
noremap <leader>C <cmd>cclose<cr>
nnoremap ]q <cmd>cnext<cr>
nnoremap [q <cmd>cprev<cr>
nnoremap <C-s> <cmd>write<cr>
nnoremap <leader>q <cmd>quit<cr>
nnoremap <leader>d <cmd>bdelete<cr>
nnoremap <leader>x :terminal<space>
nnoremap <leader>X :below terminal<space>
nnoremap zl 10zl
nnoremap zh 10zh

augroup QuickfixWindow
  autocmd!
  autocmd FileType qf 6wincmd _
augroup END

augroup YankHighlight
  autocmd!
  autocmd TextYankPost * lua vim.hl.on_yank({ higroup = 'Visual', timeout = 300 })
augroup END

" 禁用 netrw
let g:loaded_netrwPlugin = 1
let g:loaded_netrw = 0

lua require("config.lazy")
