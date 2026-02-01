-- Fix noice cmdline crash with Neovim 0.11 + treesitter
-- Issue: https://github.com/folke/noice.nvim/issues/1188
return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        enabled = true, -- Keep the fancy cmdline UI
        format = {
          -- Disable treesitter highlighting in cmdline (causes crash)
          cmdline = { lang = "" },
          search_down = { lang = "" },
          search_up = { lang = "" },
          filter = { lang = "" },
          lua = { lang = "" },
          help = { lang = "" },
          input = { lang = "" },
        },
      },
    },
  },
}
