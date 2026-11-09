return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-mini/mini.icons' },
  lazy = false,
  keys = {
    { '<leader>f', '<cmd>FzfLua files<cr>', desc = 'Find files' },
    { '<leader>s', '<cmd>FzfLua builtin<cr>', desc = 'Fzf builtin' },
    {
      '<leader>e',
      ':Files <C-R>=fnameescape(expand("%:~:h"))<CR>/',
      desc = 'Find files in buffer directory',
    },
    { '<leader>,', '<cmd>History<cr>', desc = 'Oldfiles' },
    { '<leader>a', '<cmd>FzfLua resume<cr>', desc = 'Fzf resume' },
    { '<leader>b', '<cmd>FzfLua buffers<cr>', desc = 'Fzf buffers' },
    -- { '<leader>sF', '<cmd>FzfLua git_files<cr>', desc = 'Find Git files' },
    -- { '<leader>r', '<cmd>Rg <cr>', desc = 'grep' },
    { '<leader>r', '<cmd>FzfLua live_grep<cr>', desc = 'Fzf live grep' },
    -- { '<leader>,', '<cmd>FzfLua buffers<cr>', desc = 'Buffers' },
    { '<leader>l', '<cmd>FzfLua blines<cr>', desc = 'Fzf search open buffer lines' },
  },
  config = function(_, opts)
    local fzf = require('fzf-lua')
    fzf.setup(opts)
    -- The fzf-vim profile's :Files command does not define path completion.
    vim.api.nvim_del_user_command('Files')
    vim.api.nvim_create_user_command(
      'Files',
      fzf.utils.create_user_command_callback('files', 'cwd'),
      {
        bang = true,
        nargs = '?',
        complete = 'dir',
      }
    )
  end,
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
