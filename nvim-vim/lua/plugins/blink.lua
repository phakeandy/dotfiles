return {
  'saghen/blink.cmp',
  version = '1.*',
  event = 'InsertEnter',
  dependencies = {
    'L3MON4D3/LuaSnip',
  },
  opts = function()
    return {
      keymap = {
        preset = 'default',
      },
      snippets = { preset = 'luasnip' },
      sources = {
        -- AI suggestions use Minuet virtual text, not the completion menu.
        default = { 'lsp', 'path', 'buffer', 'snippets' },
      },
      completion = { trigger = { prefetch_on_insert = false } },
    }
  end,
}
