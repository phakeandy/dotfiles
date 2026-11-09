local entrypath = function()
  local oil = require('oil')
  local entry = oil.get_cursor_entry()
  local dir = oil.get_current_dir()

  if not entry or not dir then return end

  return vim.fs.joinpath(dir, entry.name)
end

local cwd = function() return require('oil').get_current_dir() end

return {
  'stevearc/oil.nvim',
  -- enabled = false,
  lazy = false,
  keys = {
    { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
    { '_', '<cmd>Oil .<cr>', desc = 'Open cwd directory' },
  },
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    columns = {},
    keymaps = {
      ['<leader>y'] = {
        desc = 'Copy relative filepath to system clipboard',
        callback = function()
          if entrypath() then
            vim.cmd(string.format('let @+ = fnamemodify(%s, :.)', entrypath()))
          end
        end,
      },
      ['<leader>Y'] = {
        desc = 'Copy filepath to system clipboard',
        callback = function()
          if entrypath() then
            vim.cmd(string.format('let @+ = fnamemodify(%s, :p:~)', entrypath()))
          end
        end,
      },
      ['<leader>x'] = {
        desc = 'Run shell command in this directory',
        expr = true,
        replace_keycodes = false,
        callback = function()
          local cwd = cwd()
          return string.format(':terminal cd %s && ', vim.fn.shellescape(cwd)) or ''
        end,
      },
      -- Fuzzy finder
      ['<leader>f'] = {
        desc = 'Find files from here',
        callback = function() require('fzf-lua').files({ cwd = cwd() }) end,
      },
      ['<leader>r'] = {
        desc = 'Find files from here',
        callback = function() require('fzf-lua').live_grep({ cwd = cwd() }) end,
      },
    },
  },
}
