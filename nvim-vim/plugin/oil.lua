vim.pack.add({
  'https://github.com/stevearc/oil.nvim',
}, { confirm = false })

require('oil').setup({
  keymaps = {
    ['gy'] = {
      desc = 'Copy relative filepath to system clipboard',
      callback = function()
        local entry = require('oil').get_cursor_entry()
        local dir = require('oil').get_current_dir()
        if not entry or not dir then return end
        local relpath = vim.fn.fnamemodify(dir, ':.')
        vim.fn.setreg('+', relpath .. entry.name)
      end,
    },
    ['gY'] = {
      desc = 'Copy filepath to system clipboard',
      callback = function()
        require('oil.actions').copy_entry_path.callback()
        vim.fn.setreg('+', vim.fn.getreg(vim.v.register))
      end,
    },
    ['<leader>x'] = {
      callback = function()
        local dir = require('oil').get_current_dir()
        if dir then
        -- stylua: ignore
        vim.api.nvim_feedkeys(string.format(":!cd %s && ", vim.fn.fnameescape(dir)), "n", false)
        end
      end,
      desc = 'Run shell command in this directory',
    },
  },
})
