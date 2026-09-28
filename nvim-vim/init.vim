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
nnoremap <silent> <leader>yp :let @+ = expand("%:p:~")<cr>
nnoremap <silent> <leader>yy :let @+ = expand("%:p:~") . ":" . line(".")<cr>

set number relativenumber
set clipboard=unnamedplus
set breakindent
set formatoptions+=Mm " include the chinese charactor
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
" Keep a blinking block cursor in every Neovim mode.
set guicursor=a:block-blinkwait500-blinkon500-blinkoff500
"set cmdheight=0 laststatus=3 statusline=
set noshowmode
set wrap
set exrc
set splitright splitbelow
set smarttab smartindent
set formatoptions+=Mm " include the chinese charactor
set listchars=tab:\»\ ,trail:·,nbsp:␣,precedes:<,extends:>
set completeopt=longest,menuone,popup pumheight=6
set mousescroll=ver:1 " For Ghosstty's bug: https://github.com/ghostty-org/ghostty/discussions/3955?utm_source=chatgpt.com

lua << EOF
vim.diagnostic.config({
  --severity_sort = true,
  virtual_text = true,
  signs = false,
  --underline = { severity = { min = vim.diagnostic.severity.ERROR } },
})
EOF

lua << EOF
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

lua << EOF
local columns_before_wrap
vim.keymap.set('n', '<M-z>', function()
  if vim.wo.wrap then
    vim.wo.wrap = false
    if columns_before_wrap then
      vim.o.columns = columns_before_wrap
      columns_before_wrap = nil
    end
  else
    columns_before_wrap = vim.o.columns
    vim.wo.wrap = true
    vim.o.columns = 80
  end
end, { desc = 'Toggle wrap and columns 80' })
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
  autocmd TextYankPost * lua vim.hl.hl_op({ higroup = 'IncSearch', timeout = 300 })
augroup END

" 禁用 netrw
let g:loaded_netrwPlugin = 1
let g:loaded_netrw = 0

lua require("config.lazy")
