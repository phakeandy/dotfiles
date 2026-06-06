vim.keymap.set('n', '<leader>x', [["9yip}:put =system(getreg('9'))<cr>]])

-- lua version (took me 2 hours, but i got a keymapping implementing almost same function)
-- local feed = function(keys) vim.api.nvim_feedkeys(vim.keycode(keys), 'x', false) end
-- vim.keymap.set('n', '<leader>x', function()
--   local reg = '9' -- no mater what register use
--   local original_text = vim.fn.getreg(reg)
--   feed('"' .. reg .. 'yip')
--   feed('}')
--   local res = vim
--     .system({ 'bash', '-c', vim.fn.getreg(reg) }, { text = true })
--     :wait()
--   vim.fn.setreg(reg, res.stdout)
--   feed('"' .. reg .. 'p')
--   vim.fn.setreg(reg, original_text)
-- end)
