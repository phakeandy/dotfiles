-- blink.cmp 的中文分词补全源
--
-- 背景：blink.cmp 用 \p{L} / \k 判断 keyword，一整串连续汉字会被当成一个
-- keyword，于是自带的 buffer 源只能补“整句”。这个源借助 jieba.vim 的分词
-- 结果，把 buffer 里的中文切成词，再用显式的 filterText/textEdit 绕开
-- keyword 的限制，给出按词（而不是按句）的补全。
--
-- 匹配思路：取光标前连续汉字的后缀（从长到短）去 buffer 里找，
--   * 后缀刚好结束在一个词边界 -> 补后面的词（纯插入）
--   * 后缀是某个词的开头        -> 把整词补全（替换已输入部分）

local Kind = require('blink.cmp.types').CompletionItemKind

local MAX_SUFFIX_CHARS = 10 -- 最多取光标前几个汉字去找上下文
local MAX_MATCHES = 20 -- 每次最多处理多少个匹配（分词是主要开销）
local MAX_FIND = 200 -- 每次最多收集多少个匹配
local MAX_CANDIDATES = 50 -- 最多返回多少个补全项
local MAX_SCAN_CANDIDATES = 12 -- 收满这么多候选就不再往下找了
local WINDOW_LINES = 2000 -- 只在光标附近这么多行里找
local MAX_SEG_CACHE = 4000 -- 分词缓存条数上限
local MAX_LINE_BYTES = 4000 -- 超长行不做分词

local M = {}

local seg_cache = {}
local seg_cache_size = 0
local word_motion = nil
local word_motion_failed = false

--- 是否是汉字（CJK）
local function is_han(cp)
  return (cp >= 0x3400 and cp <= 0x4DBF)
    or (cp >= 0x4E00 and cp <= 0x9FFF)
    or (cp >= 0xF900 and cp <= 0xFAFF)
    or (cp >= 0x20000 and cp <= 0x3134F)
end

local function has_han(s)
  for i = 1, #s do
    local b = s:byte(i)
    if b >= 0xE0 then
      local len = b >= 0xF0 and 4 or 3
      if is_han(vim.fn.char2nr(s:sub(i, i + len - 1))) then return true end
    end
  end
  return false
end

--- 把一行拆成字符（0-based 字节区间）
function M._chars(line)
  local out = {}
  local i, n = 0, #line
  while i < n do
    local b = line:byte(i + 1)
    local len = 1
    if b >= 0xF0 then
      len = 4
    elseif b >= 0xE0 then
      len = 3
    elseif b >= 0xC0 then
      len = 2
    end
    out[#out + 1] = { char = line:sub(i + 1, i + len), start = i, stop = i + len }
    i = i + len
  end
  return out
end

--- 光标前连续的汉字（按字符返回）
local function han_run_before(line, col)
  local cs = M._chars(line)
  local last = nil
  for i = #cs, 1, -1 do
    if cs[i].stop <= col then
      last = i
      break
    end
  end
  if not last then return {} end

  local i = last
  while i >= 1 and is_han(vim.fn.char2nr(cs[i].char)) do
    i = i - 1
  end
  local run = {}
  for j = i + 1, last do
    run[#run + 1] = cs[j]
  end
  return run
end

--- 拿到 jieba.vim 的 WordMotion（用于分词），失败则返回 nil
local function get_word_motion()
  if word_motion then return word_motion end
  if word_motion_failed then return nil end

  local ok, jv = pcall(require, 'jieba_vim')
  if not ok then
    word_motion_failed = true
    return nil
  end
  if not jv.word_motion then
    pcall(vim.fn['jieba_vim#loader#ensure_loaded'])
  end
  if not jv.word_motion then
    word_motion_failed = true
    return nil
  end
  word_motion = jv.word_motion
  return word_motion
end

--- 对一行做分词，返回 { text, start, stop } 列表（0-based 字节区间）
--- 按行内容缓存，行内容不变就不用重新分词
local function segment_line(line, lnum)
  local cached = seg_cache[line]
  if cached then return cached end
  if #line > MAX_LINE_BYTES then return nil end

  local wm = get_word_motion()
  if not wm then return nil end

  local buffer = {
    getline = function(l) return l == lnum and line or '' end,
    lines = function() return lnum end,
  }
  local ok, positions = pcall(wm.preview_nmap, wm, buffer, 'w', { 0, lnum, 1, 0, 1 }, 0)
  if not ok then return nil end

  local starts = { 1 }
  for _, pos in ipairs(positions) do
    local c = pos[2]
    if c > starts[#starts] then starts[#starts + 1] = c end
  end

  local tokens = {}
  for i, s in ipairs(starts) do
    local e = (starts[i + 1] or (#line + 1)) - 1
    tokens[i] = { text = line:sub(s, e), start = s - 1, stop = e }
  end

  if seg_cache_size >= MAX_SEG_CACHE then
    seg_cache = {}
    seg_cache_size = 0
  end
  seg_cache[line] = tokens
  seg_cache_size = seg_cache_size + 1
  return tokens
end

--- 在 lines[from..to] 里找 S 的所有出现，跳过光标处那一次
local function find_matches(lines, from, to, S, cursor_row, col)
  local matches = {}
  local slen = #S
  for lnum = from, to do
    local l = lines[lnum]
    if l and #l >= slen then
      local init = 1
      while true do
        local s = l:find(S, init, true)
        if not s then break end
        local start_byte = s - 1
        -- 跳过光标处刚输入的那一次
        local at_cursor = lnum == cursor_row and start_byte + slen == col
        if not at_cursor then
          matches[#matches + 1] = { lnum = lnum, start = start_byte, stop = start_byte + slen }
          if #matches >= MAX_FIND then return matches end
        end
        init = s + 1
      end
    end
  end
  return matches
end

local function add_candidate(cands, key, label, new_text, replace_bytes, score)
  if cands[key] then return end
  cands[key] = { label = label, new_text = new_text, replace = replace_bytes, score = score }
end

--- 根据一个匹配生成候选项
local function candidates_from_match(cands, match, lines)
  local line = lines[match.lnum]
  local tokens = segment_line(line, match.lnum)
  if not tokens then return end

  -- 覆盖 match.start 的词
  local i
  for idx, t in ipairs(tokens) do
    if t.start <= match.start and match.start < t.stop then
      i = idx
      break
    end
  end
  if not i then return end

  -- match 结束落在哪个词里
  local j
  for idx = i, #tokens do
    local t = tokens[idx]
    if t.start < match.stop and match.stop <= t.stop then
      j = idx
      break
    end
  end
  if not j then return end

  -- 1. 后缀刚好结束在一个词边界：补后面的词
  if tokens[j].stop == match.stop then
    local t1 = tokens[j + 1]
    if t1 and has_han(t1.text) then
      local n = vim.fn.strchars(t1.text)
      add_candidate(cands, 'b1:' .. t1.text, t1.text, t1.text, 0, 3000 + n)

      local t2 = tokens[j + 2]
      if t2 and has_han(t2.text) then
        local phrase = t1.text .. t2.text
        local pn = vim.fn.strchars(phrase)
        add_candidate(cands, 'b2:' .. phrase, phrase, phrase, 0, 2000 + pn)
      end
    end
    return
  end

  -- 2. 后缀是某个词的开头：补全这个整词
  local t = tokens[i]
  if i == j and t.start == match.start and t.text:sub(1, #match.text) == match.text then
    local n = vim.fn.strchars(t.text)
    add_candidate(cands, 'p1:' .. t.text, t.text, t.text, #match.text, 4000 + n)
  end
end

--- 构造补全项
local warned = false
function M:get_completions(ctx, callback)
  local items = {}
  local ok, result = pcall(M._get_items, self, ctx)
  if ok then
    items = result
  elseif not warned then
    warned = true
    vim.notify('zh_cmp: ' .. tostring(result), vim.log.levels.WARN)
  end
  callback({ items = items, is_incomplete_forward = true, is_incomplete_backward = true })
end

function M._get_items(_, ctx)
  if ctx.mode ~= 'default' then return {} end

  local line, col = ctx.line, ctx.cursor[2]
  local run = han_run_before(line, col)
  if #run == 0 then return {} end

  local lines = vim.api.nvim_buf_get_lines(ctx.bufnr, 0, -1, false)
  local cursor_row = ctx.cursor[1]

  -- 只看光标附近的行
  local from, to = 1, #lines
  if #lines > WINDOW_LINES then
    from = math.max(1, cursor_row - math.floor(WINDOW_LINES / 2))
    to = math.min(#lines, from + WINDOW_LINES - 1)
  end

  local cands = {}
  local kmax = math.min(#run, MAX_SUFFIX_CHARS)
  for k = kmax, 1, -1 do
    local parts = {}
    for m = #run - k + 1, #run do
      parts[#parts + 1] = run[m].char
    end
    local suffix = table.concat(parts)

    local matches = find_matches(lines, from, to, suffix, cursor_row, col)
    if #matches > 1 then
      -- 优先用离光标近的行
      table.sort(matches, function(a, b)
        return math.abs(a.lnum - cursor_row) < math.abs(b.lnum - cursor_row)
      end)
    end
    local cand_count = 0
    for idx, match in ipairs(matches) do
      if idx > MAX_MATCHES then break end
      match.text = suffix
      candidates_from_match(cands, match, lines)
      cand_count = vim.tbl_count(cands)
      if cand_count >= MAX_SCAN_CANDIDATES then break end
    end

    if cand_count > 0 then break end
  end

  -- 排序并生成 blink 的 item
  local list = {}
  for _, c in pairs(cands) do
    list[#list + 1] = c
  end
  table.sort(list, function(a, b) return a.score > b.score end)

  local keyword = ctx.get_keyword()
  local row = ctx.cursor[1] - 1
  local items = {}
  for idx = 1, math.min(#list, MAX_CANDIDATES) do
    local c = list[idx]
    items[idx] = {
      label = c.label,
      insertText = c.new_text,
      insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
      kind = Kind.Text,
      -- keyword 是一整段汉字，这里拼进去保证 blink 的模糊过滤不会把候选丢掉
      filterText = keyword .. '\n' .. c.label,
      score_offset = c.score,
      textEdit = {
        newText = c.new_text,
        range = {
          start = { line = row, character = col - c.replace },
          ['end'] = { line = row, character = col },
        },
      },
    }
  end
  return items
end

function M:new(_)
  -- blink 在进入插入模式时才实例化 provider，这里顺便预热词典
  vim.defer_fn(M.warmup, 500)
  return setmetatable({}, { __index = M })
end

--- 预热 jieba 词典（首次分词约 100ms），避免第一次补全卡顿
local warmed = false
function M.warmup()
  if warmed then return end
  if not get_word_motion() then return end
  local bufnr = vim.api.nvim_get_current_buf()
  local n = math.min(200, vim.api.nvim_buf_line_count(bufnr))
  local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, n, false), '\n')
  if not has_han(text) then return end
  warmed = true
  segment_line('中文分词', 1)
end

-- 进入插入模式后（当前 buffer 里有汉字时）预热词典
vim.api.nvim_create_autocmd('InsertEnter', {
  group = vim.api.nvim_create_augroup('ZhCmpWarmup', { clear = true }),
  callback = function() vim.defer_fn(M.warmup, 200) end,
})

vim.api.nvim_create_user_command('ZhCmpSeg', function()
  local tokens = segment_line(vim.api.nvim_get_current_line(), vim.fn.line('.'))
  if not tokens then
    print('zh_cmp: 分词不可用（需要 jieba.vim）')
    return
  end
  local out = {}
  for _, t in ipairs(tokens) do out[#out + 1] = t.text end
  print(table.concat(out, ' | '))
end, { desc = '显示当前行的中文分词结果' })

return M
