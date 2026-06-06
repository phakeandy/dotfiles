if true then return {} end

local nmap = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end

vim.pack.add({
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',

  -- needs run `cd /home/phakeandy/.local/share/nvim/site/pack/core/opt/telescope-fzf-native.nvim/ && make`
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
}, { confirm = false })

require('telescope').setup({
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown({}) },
  },
})
require('telescope').load_extension('ui-select')
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')

-- stylua: ignore start
nmap("<leader>f", builtin.find_files, "Telescope find files")
-- nmap("<c-p>", builtin.find_files, "Telescope find files")
nmap("<leader>,", builtin.buffers, "Telescope buffers")
nmap("<leader>.", builtin.buffers, "Telescope oldfiles")
nmap("<leader>sc", function() builtin.find_files({ cwd = vim.fn.stdpath("config") }) end, "Telescope find neovim configuraition files")
nmap("<leader>sh", builtin.help_tags, "Telescope help tags")
nmap("<leader>so", builtin.oldfiles, "Telescope old tags")
nmap("<leader>/", builtin.live_grep, "Telescope live grep" )
nmap("<leader>st", builtin.builtin, "Telescope")
-- stylua: ignore end
