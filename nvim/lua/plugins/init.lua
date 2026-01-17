vim.pack.add {
  { src = "https://github.com/nvim-lua/plenary.nvim" },
}


local scan = require("plenary.scandir")
local plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins"

-- scandir.scan_dir 直接返回目录下所有匹配的文件路径
local files = scan.scan_dir(plugins_dir, {
  depth = 1,
  search_pattern = ".lua"
})

for _, file in ipairs(files) do
  -- 提取文件名（不带后缀），例如 "/path/to/lualine.lua" -> "lualine"
  local module_name = vim.fn.fnamemodify(file, ":t:r")
  -- 核心逻辑：排除 init.lua 本身，并安全加载
  if module_name ~= "init" then
    local status, err = pcall(require, "plugins." .. module_name)
    -- 如果加载出错，弹出浮窗提示，方便调试
    if not status then
      vim.notify(
        string.format("Failed to load [plugins.%s]: %s", module_name, err),
        vim.log.levels.ERROR,
        { title = "Plugin Config Loader" }
      )
    end
  end
end
