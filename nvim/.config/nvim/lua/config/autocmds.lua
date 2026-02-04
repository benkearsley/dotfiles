-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Clean shutdown: stop LSP clients before exit to prevent race conditions
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("clean_shutdown", { clear = true }),
  callback = function()
    -- TMUX-specific: Extra aggressive shutdown
    if vim.env.TMUX then
      -- Disable UI updates immediately
      vim.opt.lazyredraw = true
      -- Stop all UI plugins
      pcall(require, "noice")  -- Noice can interfere
      pcall(vim.cmd, "NoiceDisable")
    end
    
    -- Stop all LSP clients gracefully
    for _, client in ipairs(vim.lsp.get_clients()) do
      client.stop()
    end
    
    -- Give them a moment to shut down
    vim.wait(vim.env.TMUX and 200 or 100)  -- Longer wait in tmux
  end,
})
