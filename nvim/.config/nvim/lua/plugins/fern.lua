-- fern.vim：纯 Vimscript 的异步树（Vim / Neovim 都能跑）。
-- 配置只能用 :Fern 命令 + g: 变量，没有 Lua API。
local function reveal()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' or vim.bo.filetype == 'fern' then return end

  local fern_buf
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'fern' then
      fern_buf = buf
      break
    end
  end

  if fern_buf then
    -- FernReveal 会把绝对路径换算成相对当前 root 的路径
    vim.api.nvim_buf_call(
      fern_buf,
      function() vim.cmd('FernReveal ' .. vim.fn.fnameescape(file)) end
    )
  else
    local dir = vim.fn.fnameescape(vim.fn.fnamemodify(file, ':h'))
    local name = vim.fn.fnameescape(vim.fn.fnamemodify(file, ':t'))
    vim.cmd('Fern ' .. dir .. ' -drawer -right -reveal=' .. name)
  end
end

return {
  'lambdalisue/fern.vim',
  dependencies = {
    'lambdalisue/nerdfont.vim', -- 图标字典，渲染器依赖它
    'lambdalisue/fern-renderer-nerdfont.vim', -- nerd font 图标
    'lambdalisue/glyph-palette.vim', -- 给图标上色
    'lambdalisue/fern-git-status.vim', -- 节点上显示 git 状态
  },
  enabled = false,
  -- 懒加载：第一次按 <leader>e 才加载，不拖启动
  keys = {
    {
      '<leader>e',
      '<cmd>Fern . -drawer -right -toggle<cr>',
      desc = 'Toggle file tree (fern)',
    },
    { '<leader>E', reveal, desc = 'Reveal current file in tree' },
  },
  -- g: 变量必须在 fern 加载前设好，所以放 init
  init = function()
    vim.g['fern#renderer'] = 'nerdfont'
    vim.g['fern#drawer_width'] = 32
    -- 1 = 显示 .dotfiles（dotfiles 仓库里这很重要）
    vim.g['fern#default_hidden'] = 1
  end,
  config = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'fern',
      callback = function(args)
        local function map(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, {
            buffer = args.buf,
            nowait = true,
            desc = desc,
          })
        end

        -- a = 新建，结尾带 / 就建目录（fern 原生的 new-path 正是这个语义）
        map('a', '<Plug>(fern-action-new-path)', 'New file/dir')
        -- fern 原本的 a（动作选择器）挪到 <Space>a，给它留个更"像命令"的位置
        map('<leader>a', '<Plug>(fern-action-choice)', 'Action panel (fern choice)')
        -- 关抽屉：和 nvim-tree/nerd 的手感一致
        map('q', '<cmd>close<cr>', 'Close tree')

        -- 图标上色（glyph-palette 的用法就是 FileType 时调一次）
        pcall(vim.fn['glyph_palette#apply'])
      end,
    })
  end,
}
