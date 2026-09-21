return {
  'L3MON4D3/LuaSnip',
  event = 'InsertEnter',
  config = function()
    local luasnip = require('luasnip')
    require('luasnip.loaders.from_snipmate').lazy_load()
    vim.keymap.set({ 'i', 's' }, '<Tab>', function()
      if luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else return '<Tab>' end
    end, { expr = true, silent = true })
    vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
      if luasnip.jumpable(-1) then luasnip.jump(-1) else return '<S-Tab>' end
    end, { expr = true, silent = true })
    vim.keymap.set({ 'i', 's' }, '<C-E>', function()
      if luasnip.choice_active() then luasnip.change_choice(1) else return '<C-E>' end
    end, { expr = true, silent = true })
  end,
}
