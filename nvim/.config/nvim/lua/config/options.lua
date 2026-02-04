-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- TMUX compatibility: prevent TUI race conditions
if vim.env.TMUX then
  vim.opt.titlestring = "nvim %f"  -- Simpler title in tmux
  vim.opt.title = true
  -- Reduce UI update frequency in tmux to prevent race conditions
  vim.opt.updatetime = 300
end
