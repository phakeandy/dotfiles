return {
  'max397574/better-escape.nvim',
  -- 不能用 event = 'InsertEnter'：进 terminal 模式不算 insert，InsertEnter 不会触发，
  -- 所以直接开终端时插件根本没加载，jk 映射就不存在（先进一次 insert 后才会好）。
  -- 插件只有两个文件，直接常驻；TermOpen 也会晚一拍，别省这个。
  lazy = false,
  opts = {
    timeout = vim.o.timeoutlen,
    default_mappings = false,
    mappings = {
      i = {
        j = {
          k = '<Esc>',
        },
      },
      t = {
        j = {
          k = '<C-\\><C-n>',
        },
      },
    },
  },
}
