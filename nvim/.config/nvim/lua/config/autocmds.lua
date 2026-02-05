vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- 在右侧打开 help page
vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	callback = function()
		vim.cmd("wincmd L")
	end,
})

-- IME

-- Windows 下用 im-select.exe 的完整逻辑
local im_check_cmd = "im-select.exe" -- 查询
local im_off_cmd = "im-select.exe 1033" -- 英文
local im_on_cmd = "im-select.exe 2052" -- 中文（母语）

-- 判断“当前是不是英文”
local function im_isoff(im)
	return tonumber(im) == 1033
end

local method_toggled = false

-- 离开插入模式：不是英文就切成英文，并做标记
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		local im = vim.fn.system(im_check_cmd):gsub("%s+", "") -- 去掉换行
		if not im_isoff(im) then
			vim.fn.system(im_off_cmd)
			method_toggled = true
		else
			method_toggled = false
		end
	end,
})

-- 进入插入模式：如果之前是我切的，就恢复中文
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	callback = function()
		if method_toggled then
			vim.fn.system(im_on_cmd)
			method_toggled = false
		end
	end,
})
