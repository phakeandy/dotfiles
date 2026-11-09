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
        preset = 'super-tab', -- Uses Tab to accept completions and move through snippets
      },
      snippets = { preset = 'luasnip' },
      sources = {
        -- AI suggestions use Minuet virtual text, not the completion menu.
        default = { 'lsp', 'path', 'buffer', 'snippets' },
      },
      -- completion = { trigger = { prefetch_on_insert = false } },

      completion = {
        -- Show inline ghost text as you type, just like VS Code IntelliSense
        ghost_text = { enabled = true },

        -- Automatically select the first item without inserting it
        list = { selection = { preselect = true, auto_insert = false } },

        -- Documentation window behavior
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
    }
  end,
}
