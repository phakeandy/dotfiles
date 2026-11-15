-- Markdown 行内 text object，基于 Neovim 自带的 markdown_inline parser
-- （parser 随 Neovim 发布，无需 nvim-treesitter）。
--
--   i* a*   **bold**              strong_emphasis
--   i_ a_   *italic* / _italic_   emphasis
--   i` a`   `code`                code_span
--   i~ a~   ~~strike~~            strikethrough
--   il al   [text](url)           al = 整个链接，il = [] 里的文字
--   im am   光标处最内层的行内对象（以上任意一种）
--
-- i 开头 = 不含标记，a 开头 = 含标记。只在 markdown buffer 生效。

local M = {}

local DELIM = { emphasis_delimiter = true, code_span_delimiter = true }

local OBJECTS = {
  ['*'] = { 'strong_emphasis' },
  ['_'] = { 'emphasis' },
  ['`'] = { 'code_span' },
  ['~'] = { 'strikethrough' },
  ['l'] = { 'inline_link', 'full_reference_link', 'shortcut_link', 'image' },
}

local ANY = {
  'strong_emphasis',
  'emphasis',
  'code_span',
  'strikethrough',
  'inline_link',
  'full_reference_link',
  'shortcut_link',
  'image',
}

local function children(node)
  local res = {}
  for child in node:iter_children() do res[#res + 1] = child end
  return res
end

-- 去掉首尾的 delimiter：**bold** -> bold，~~x~~ -> x（strikethrough 是两层节点）
local function inner_range(node)
  local ntype = node:type()
  if ntype:find('link') or ntype == 'image' then
    for _, child in ipairs(children(node)) do
      local ct = child:type()
      if ct == 'link_text' or ct == 'image_description' then return child:range() end
    end
  end

  local sr, sc, er, ec = node:range()
  while true do
    local kids = children(node)
    if #kids == 0 then break end

    local first = 1
    while kids[first] and DELIM[kids[first]:type()] do
      local ksr, ksc, ker, kec = kids[first]:range()
      if ksr ~= sr or ksc ~= sc then break end
      sr, sc = ker, kec
      first = first + 1
    end

    local last = #kids
    while last >= first and DELIM[kids[last]:type()] do
      local ksr, ksc, ker, kec = kids[last]:range()
      if ker ~= er or kec ~= ec then break end
      er, ec = ksr, ksc
      last = last - 1
    end

    -- 唯一子节点且同类型（strikethrough 包 strikethrough）时继续往里钻
    if last == first and kids[last] and kids[last]:type() == ntype then
      local ksr, ksc, ker, kec = kids[last]:range()
      if ksr ~= sr or ksc ~= sc or ker ~= er or kec ~= ec then break end
      node = kids[last]
    else
      break
    end
  end
  return sr, sc, er, ec
end

local function anchor_node(types)
  local buf = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, buf, 'markdown_inline')
  if not ok or not parser then return end
  if not pcall(parser.parse, parser) then return end

  local ok2, node = pcall(vim.treesitter.get_node, {
    bufnr = buf,
    lang = 'markdown_inline',
    ignore_injections = true,
  })
  if not ok2 or not node then return end

  local wanted = {}
  for _, t in ipairs(types) do wanted[t] = true end
  local found
  while node do
    if wanted[node:type()] then
      found = node
      break
    end
    node = node:parent()
  end
  -- ~~x~~ 的语法树是 strikethrough 套 strikethrough，往外爬到最外层
  while found do
    local parent = found:parent()
    if parent and parent:type() == found:type() then
      found = parent
    else
      break
    end
  end
  return found
end

-- 树里的 end col 是开区间；转成选区最后一个字符的列（按字符边界回退，中文安全）
local function last_char_col(row, ecol)
  if ecol == 0 then
    row = row - 1
    ecol = #(vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or '')
  end
  local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ''
  local i = ecol - 1
  while i > 0 do
    local b = line:byte(i + 1)
    if b and b >= 0x80 and b < 0xC0 then i = i - 1 else break end
  end
  return row, math.max(i, 0)
end

local function select_range(sr, sc, er, ec, mode)
  if er < sr or (er == sr and ec <= sc) then return end
  er, ec = last_char_col(er, ec)
  if er < sr or (er == sr and ec < sc) then return end

  if mode == 'x' then vim.cmd('normal! \27') end -- 丢掉原来的选区
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, { er + 1, ec })
end

function M.select(types, around, mode)
  local node = anchor_node(types)
  if not node then return end
  local sr, sc, er, ec
  if around then
    sr, sc, er, ec = node:range()
  else
    sr, sc, er, ec = inner_range(node)
  end
  select_range(sr, sc, er, ec, mode)
end

function M.setup_buffer(buf)
  for key, types in pairs(OBJECTS) do
    for _, prefix in ipairs({ 'i', 'a' }) do
      for _, mode in ipairs({ 'x', 'o' }) do
        local around = prefix == 'a'
        vim.keymap.set(mode, prefix .. key, function() M.select(types, around, mode) end, {
          buffer = buf,
          desc = (around and 'around ' or 'inner ') .. vim.inspect(types):gsub('[%{%}%[%]"]', ''),
        })
      end
    end
  end
  for _, prefix in ipairs({ 'i', 'a' }) do
    for _, mode in ipairs({ 'x', 'o' }) do
      local around = prefix == 'a'
      vim.keymap.set(mode, prefix .. 'm', function() M.select(ANY, around, mode) end, {
        buffer = buf,
        desc = (around and 'around ' or 'inner ') .. 'markdown inline object',
      })
    end
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'markdown.mdx', 'rmd', 'quarto' },
  group = vim.api.nvim_create_augroup('MarkdownTextObjects', { clear = true }),
  callback = function(args) M.setup_buffer(args.buf) end,
})

return M
