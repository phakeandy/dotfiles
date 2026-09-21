return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-mini/mini.icons' },
  lazy = false,
  keys = {
    { '<leader>f', '<cmd>FzfLua files<cr>', desc = 'Find files' },
    { '<leader>sf', '<cmd>FzfLua files<cr>', desc = 'Find files' },
    { '<leader>sF', '<cmd>FzfLua git_files<cr>', desc = 'Find Git files' },
    { '<leader>r', '<cmd>FzfLua grep<cr>', desc = 'Live grep' },
    { '<leader>,', '<cmd>FzfLua buffers<cr>', desc = 'Buffers' },
    -- { '<C-l>', '<cmd>FzfLua blines<cr>', desc = 'Search open buffer lines' },
  },
  opts = {
    'fzf-vim',
    winopts = {
      width = 0.9,
      height = 0.8,
      preview = {
        hidden = true,
        layout = 'horizontal',
        horizontal = 'right:40%',
      },
    },
    fzf_opts = { ['--layout'] = 'reverse' },
    files = {
      rg_opts = table.concat({
        '--color=never',
        '--files',
        '--hidden',
        '-g "!.git"',
        '-g "!node_modules"',
        '-g "!target"',
        '-g "!dist"',
        '-g "!.venv"',
        '-g "!*.pyc"',
        '-g "!__pycache__"',
      }, ' '),
    },
  },
}
