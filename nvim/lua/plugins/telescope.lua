vim.pack.add({
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
})

require("telescope").setup({
  defaults = {},
  pickers = {
    buffers = {
      initial_mode = "normal",
    },
  },
  extensions = {},
})

vim.keymap.set(
  "n",
  "sf",
  require("telescope.builtin").find_files,
  { desc = "Telescope find files" }
)

vim.keymap.set("n", "sc", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Telescope find neovim configuraition files" })

vim.keymap.set("n", "sg", require("telescope.builtin").live_grep, { desc = "Telescope live grep" })

vim.keymap.set(
  "n",
  "<leader><leader>",
  require("telescope.builtin").buffers,
  { desc = "Telescope buffers" }
)
vim.keymap.set("ca", "ls", function()
  require("telescope.builtin").buffers(require("telescope.themes").get_ivy({}))
end, { desc = "Telescope buffers" })

vim.keymap.set("n", "sh", require("telescope.builtin").help_tags, { desc = "Telescope help tags" })
