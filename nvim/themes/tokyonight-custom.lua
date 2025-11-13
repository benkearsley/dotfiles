return {
  {
    "folke/tokyonight.nvim",
    config = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          vim.api.nvim_set_hl(0, "Normal", { bg = "#181824" })
          vim.api.nvim_set_hl(0, "NormalNC", { bg = "#181824" })
          vim.api.nvim_set_hl(0, "SignColumn", { bg = "#181824" })
          vim.api.nvim_set_hl(0, "VertSplit", { bg = "#181824" })
        end,
      })
    end,
  },
}
