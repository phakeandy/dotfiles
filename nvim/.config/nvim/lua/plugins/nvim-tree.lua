return {
  'nvim-tree/nvim-tree.lua',
  -- nvim-tree 只认 nvim-web-devicons；mini.icons 留着给 fzf-lua/lualine 用，两者不冲突
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { '<leader>e', '<cmd>NvimTreeToggle<cr>', desc = 'Toggle file tree' },
    { '<C-M-b>', '<cmd>NvimTreeToggle<cr>', desc = 'Toggle file tree' },
  },
  ---@type nvim_tree.config
  opts = {
    view = {
      -- 树放右边；80 列时留 48 列给代码（配合 <M-z> 的 80 列 wrap 模式）
      width = 32,
      side = 'right',
      preserve_window_proportions = true,
    },
    renderer = {
      group_empty = true,
      -- 树里把当前打开的文件高亮出来，切 buffer 时能一眼看到自己在哪
      highlight_opened_files = 'name',
      highlight_git = 'name',
      highlight_diagnostics = 'name',
      indent_markers = { enable = true },
    },
    -- 切换 buffer 时自动把树定位到当前文件
    update_focused_file = { enable = true, update_root = false },
    -- 树窗口内默认键位：a 新建、d 删除、r 重命名、y 复制、p 粘贴、gy 复制路径、q 关闭
  },
  config = function(_, opts)
    require('nvim-tree').setup(opts)

    -- 借 fern 的 smart_quit：关窗命令先打标记，等焦点落到树上、且树是唯一窗口时再收尾。
    -- 收尾必须延后一拍（vim.schedule）：在 :q 的 autocmd 里直接关窗口会中断外层命令，
    -- 报 E855: Autocommands caused command to abort。
    local quit_pending = false
    local function mark_quit()
      if vim.v.exiting ~= vim.NIL then return end
      quit_pending = true
      vim.defer_fn(function() quit_pending = false end, 100)
    end

    local group = vim.api.nvim_create_augroup('NvimTreeSmartQuit', { clear = true })
    vim.api.nvim_create_autocmd({ 'QuitPre', 'WinClosed' }, {
      group = group,
      callback = mark_quit,
    })
    vim.api.nvim_create_autocmd('BufEnter', {
      group = group,
      callback = function()
        if not quit_pending or vim.v.exiting ~= vim.NIL then return end
        if vim.bo.filetype ~= 'NvimTree' then return end
        quit_pending = false
        vim.schedule(function()
          if vim.v.exiting ~= vim.NIL then return end
          -- 条件可能在下一拍前变了，重新确认一次
          local wins = vim.api.nvim_tabpage_list_wins(0)
          if #wins ~= 1 then return end
          if vim.bo[vim.api.nvim_win_get_buf(wins[1])].filetype ~= 'NvimTree' then return end
          pcall(vim.cmd, 'quit')
        end)
      end,
    })
  end,
}
