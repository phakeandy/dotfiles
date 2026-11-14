return {
  'nvim-tree/nvim-tree.lua',
  -- nvim-tree 只认 nvim-web-devicons；mini.icons 留着给 fzf-lua/lualine 用，两者不冲突
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  -- 懒加载：第一次按键时才加载、才弹树
  keys = {
    { '<leader>e', '<cmd>NvimTreeToggle<cr>', desc = 'Toggle file tree' },
    {
      '<leader>E',
      '<cmd>NvimTreeFindFile<cr>',
      desc = 'Reveal current file in tree',
    },
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

    -- 借 fern 的 smart_quit 思路：关掉最后一个「非树」窗口时顺手把树也关掉，
    -- 否则 :q 之后只剩一个空侧栏，还得再退一次。
    vim.api.nvim_create_autocmd('WinClosed', {
      group = vim.api.nvim_create_augroup('NvimTreeSmartQuit', { clear = true }),
      callback = function()
        -- WinClosed 触发时窗口还在布局里，等一拍再看
        vim.schedule(function()
          if vim.v.exiting ~= 0 then return end -- :qa 之类，别插手
          local wins = vim.api.nvim_tabpage_list_wins(0)
          if #wins == 0 then return end
          for _, win in ipairs(wins) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'NvimTree' then return end
          end
          -- 只剩树了：一起关掉（如果它也是最后一个窗口，nvim 顺势退出）
          pcall(vim.cmd, 'NvimTreeClose')
        end)
      end,
    })
  end,
}
