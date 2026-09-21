return {
  'saghen/blink.cmp',
  version = '1.*',
  event = 'InsertEnter',
  dependencies = {
    'L3MON4D3/LuaSnip',
    'milanglacier/minuet-ai.nvim',
  },
  opts = function()
    return {
      keymap = {
        preset = 'default',
        ['<A-y>'] = require('minuet').make_blink_map(),
      },
      snippets = { preset = 'luasnip' },
      sources = {
        -- Minuet stays manual-only through <A-y> to avoid requests on every
        -- completion. Add 'minuet' here to enable automatic AI completion.
        default = { 'lsp', 'path', 'buffer', 'snippets' },
        providers = {
          minuet = {
            name = 'minuet',
            module = 'minuet.blink',
            async = true,
            timeout_ms = 3000,
            score_offset = 50,
          },
        },
      },
      completion = { trigger = { prefetch_on_insert = false } },
    }
  end,
}
