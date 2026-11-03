-- 多光标（nvim 0.13 内置 multicursor）对齐：把所有光标所在列用空格对齐到最右那个
-- 用法：/pattern<CR> 之后 V 选行 + [count]Q 放光标，或者 <C-LeftMouse> / [count]Q，
--       再按 <M-a>（或 :MCursorAlign）
local ns = vim.api.nvim_create_namespace('nvim.multicursor')

--- 光标前面那串空白（tab/空格）的起点，0 起的字节列
local function ws_start(line, col)
  local s = col
  while s > 0 do
    local c = line:sub(s, s) -- Lua 串 1 起，所以 sub(s,s) 是 0 起第 s-1 个字节
    if c ~= ' ' and c ~= '\t' then
      break
    end
    s = s - 1
  end
  return s
end

--- 当前缓冲区所有光标：primary + multicursor 的 extmark，row 1 起、col 是 0 起的字节列
local function positions()
  local buf = vim.api.nvim_win_get_buf(0)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local primary = vim.api.nvim_win_get_cursor(0)
  local pts, seen = {}, {}
  local function add(row, col)
    local key = ('%d:%d'):format(row, col)
    if row <= line_count and not seen[key] then
      seen[key] = true
      pts[#pts + 1] = { row = row, col = col }
    end
  end
  add(primary[1], primary[2])
  for _, m in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})) do
    add(m[2] + 1, m[3]) -- extmark 的 row 是 0 起的
  end
  return buf, pts, primary[1]
end

local function align()
  local buf, pts, primary_row = positions()

  -- 每行只留最右那个光标：Visual 选区 + Q 会留下一个落在别处的 primary，不能参与对齐
  local keep = {}
  for _, p in ipairs(pts) do
    local cur = keep[p.row]
    if not cur or p.col > cur.col then
      keep[p.row] = p
    end
  end
  local work = {}
  for _, p in ipairs(pts) do
    if keep[p.row] == p and p.col > 0 then
      work[#work + 1] = p
    end
  end
  if #work < 2 then
    return vim.notify('没有多光标', vim.log.levels.INFO)
  end

  -- 目标列取最右光标（屏幕列，tab / 宽字符都算对）
  local target = 0
  for _, p in ipairs(work) do
    target = math.max(target, vim.fn.virtcol({ p.row, p.col + 1 }))
  end

  -- 按行分组：把光标前那段空白换成空格，让它落在目标列（整行重建，一次写入）
  local rows = {}
  for _, p in ipairs(work) do
    rows[p.row] = rows[p.row] or {}
    table.insert(rows[p.row], p)
  end
  for row, list in pairs(rows) do
    table.sort(list, function(a, b)
      return a.col < b.col
    end)
    local line = vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
    local pieces, outlen, pos = {}, 0, 0
    for _, p in ipairs(list) do
      local from = math.max(ws_start(line, p.col), pos)
      local startcol = vim.fn.strdisplaywidth(line:sub(1, from)) + 1
      local repl = (' '):rep(math.max(0, target - startcol))
      local whole = line:sub(pos + 1, from) .. repl
      pieces[#pieces + 1] = whole
      outlen = outlen + #whole
      p.newcol = outlen
      pos = p.col
    end
    pieces[#pieces + 1] = line:sub(pos + 1)
    local newline = table.concat(pieces)
    if newline ~= line then
      vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { newline })
    end
  end

  -- 改文本会把 extmark 挤走，光标全部清掉重放
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local primary_col
  for _, p in ipairs(work) do
    if p.row == primary_row then
      primary_col = p.newcol
    else
      vim.api.nvim_mcursor(buf, { p.row, p.newcol })
    end
  end
  if primary_col then
    vim.api.nvim_win_set_cursor(0, { primary_row, primary_col })
  end
end

-- 多光标会话里，映射会按每个光标各回放一次，用标记保证一次按键只对齐一次
local busy = false
local function align_once()
  if busy then
    return
  end
  busy = true
  vim.schedule(function()
    busy = false
  end)
  align()
end

vim.keymap.set({ 'n', 'x' }, '<M-a>', align_once, { desc = '多光标对齐' })
vim.api.nvim_create_user_command('MCursorAlign', align, { desc = '把所有多光标对齐到最右那个列' })
