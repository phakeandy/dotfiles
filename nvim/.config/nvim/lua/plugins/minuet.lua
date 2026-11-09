return {
  'milanglacier/minuet-ai.nvim',
  opts = {
    provider = 'openai_compatible',
    request_timeout = 2.5,
    throttle = 1500,
    debounce = 600,
    virtualtext = {
      -- Manual-only by default; use :Minuet virtualtext toggle per buffer.
      auto_trigger_ft = {},
      keymap = {
        accept = '<A-A>',
        accept_line = '<A-a>',
        accept_n_lines = '<A-z>',
        prev = '<A-[>',
        next = '<A-]>',
        dismiss = '<A-e>',
      },
    },
    provider_options = {
      openai_compatible = {
        api_key = 'OPENROUTER_API_KEY',
        end_point = 'https://openrouter.ai/api/v1/chat/completions',
        model = 'deepseek/deepseek-v4-flash',
        name = 'OpenRouter',
        optional = {
          max_tokens = 56,
          top_p = 0.9,
          provider = { sort = 'throughput' },
          reasoning_effort = 'none',
        },
      },
    },
  },
  config = function(_, opts)
    require('minuet').setup(opts)
    vim.keymap.set('n', '<leader>la', '<cmd>Minuet virtualtext toggle<cr>', {
      desc = 'Minuet: toggle automatic virtual text completion',
    })
    vim.keymap.set('i', '<A-y>', function()
      require('minuet.virtualtext').action.next()
    end, { desc = 'Minuet: trigger virtual text completion' })
  end,
}
