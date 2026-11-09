-- return {
--   'nvim-mini/mini.icons',
--   version = false,
--   opts = {},
--   config = function() {
--
--   }
-- }
return {
  'nvim-mini/mini.nvim',
  version = false,
  config = function()
    -- require('mini.pairs').setup()
    require('mini.icons').setup()
  end,
}
