if true then return {} end

vim.o.completeopt = 'menuone,noselect,fuzzy'
vim.pack.add({
  {
    src = 'https://github.com/Saghen/blink.cmp',
    version = vim.version.range('1.*'),
  },
})

require('blink.cmp').setup({
  keymap = {
    -- Manually invoke minuet completion.
    ['<A-y>'] = require('minuet').make_blink_map(),
  },
  sources = {
    default = { 'lsp', 'path', 'buffer', 'snippets' },
    providers = {
      minuet = {
        name = 'minuet',
        module = 'minuet.blink',
        async = true,
        timeout_ms = 3000,
        score_offset = 50, -- Gives minuet higher priority among suggestions
      },
    },
  },
  -- Recommended to avoid unnecessary request
  completion = { trigger = { prefetch_on_insert = false } },
})
