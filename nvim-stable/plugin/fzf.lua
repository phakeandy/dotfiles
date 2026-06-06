vim.pack.add({
  'https://github.com/junegunn/fzf.vim',
})

vim.cmd('set runtimepath+=/home/phakeandy/.nix-profile/bin/fzf')

local nmap = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end

nmap('<leader>f', '<cmd>Files!<cr>')
nmap('<leader>sf', ':Files! ')
nmap('<leader>,', '<cmd>Buffers<cr>')

vim.env.FZF_DEFAULT_COMMAND = 'rg --files '
  .. "--glob '!node_modules' "
  .. "--glob '!target' "
  .. "--glob '!dist' "
  .. "--glob '!.venv' "
  .. "--glob '!*.pyc' "
  .. "--glob '!__pycache__' "

vim.env.FZF_DEFAULT_OPTS = '--layout=reverse --color=pointer:12'

-- vim.cmd([[
--
-- let $FZF_DEFAULT_OPTS=' --color=dark --color=fg:15,bg:-1,hl:1,fg+:#ffffff,bg+:0,hl+:1 --color=info:0,prompt:0,pointer:12,marker:4,spinner:11,header:-1 --layout=reverse  --margin=1,4'
-- let g:fzf_layout = { 'window': 'call FloatingFZF()' }
--
-- function! FloatingFZF()
--   let buf = nvim_create_buf(v:false, v:true)
--   call setbufvar(buf, '&signcolumn', 'no')
--
--   let height = float2nr(10)
--   let width = float2nr(80)
--   let horizontal = float2nr((&columns - width) / 2)
--   let vertical = 1
--
--   let opts = {
--         \ 'relative': 'editor',
--         \ 'row': vertical,
--         \ 'col': horizontal,
--         \ 'width': width,
--         \ 'height': height,
--         \ 'style': 'minimal'
--         \ }
--
--   call nvim_open_win(buf, v:true, opts)
-- endfunction
--
-- ]])
