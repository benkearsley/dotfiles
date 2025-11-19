-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Map `jj` to escape insert mode (silent)
vim.keymap.set("i", "jj", "<Esc>", { silent = true })
vim.opt.timeoutlen = 300
