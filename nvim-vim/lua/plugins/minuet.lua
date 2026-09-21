return {
  'milanglacier/minuet-ai.nvim',
  opts = {
    provider = 'openai_compatible',
    request_timeout = 2.5,
    throttle = 1500,
    debounce = 600,
    virtualtext = {
      auto_trigger_ft = {},
      keymap = {
        accept = '<C-f>',
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
}
