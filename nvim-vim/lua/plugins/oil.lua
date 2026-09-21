-- Kept for reference. Yazi is the active file manager.
return {
  'stevearc/oil.nvim',
  enabled = false,
  opts = {
    keymaps = {
      ['<leader>y'] = {
        desc = 'Copy relative filepath to system clipboard',
        callback = function()
          local entry = require('oil').get_cursor_entry()
          local dir = require('oil').get_current_dir()
          if not entry or not dir then return end
          vim.fn.setreg('+', vim.fn.fnamemodify(dir, ':.') .. entry.name)
        end,
      },
      ['<leader>Y'] = {
        desc = 'Copy filepath to system clipboard',
        callback = function()
          require('oil.actions').copy_entry_path.callback()
          vim.fn.setreg('+', vim.fn.getreg(vim.v.register))
        end,
      },
      ['<leader>x'] = {
        desc = 'Run shell command in this directory',
        callback = function()
          local dir = require('oil').get_current_dir()
          if dir then
            vim.api.nvim_feedkeys(
              string.format(':!cd %s && ', vim.fn.fnameescape(dir)),
              'n',
              false
            )
          end
        end,
      },
    },
  },
}
