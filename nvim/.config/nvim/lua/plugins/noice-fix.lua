-- Fix noice crashes with Neovim 0.11+
-- Addresses TUI race condition during shutdown
return {
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        enabled = true,
        format = {
          -- Disable treesitter highlighting (causes crashes)
          cmdline = { lang = "" },
          search_down = { lang = "" },
          search_up = { lang = "" },
          filter = { lang = "" },
          lua = { lang = "" },
          help = { lang = "" },
          input = { lang = "" },
        },
      },
      -- Reduce UI hooks that can cause race conditions
      lsp = {
        progress = {
          enabled = true,
          throttle = 1000 / 30, -- Throttle updates
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
      -- Important: Better shutdown handling
      routes = {
        {
          view = "notify",
          filter = { event = "msg_showmode" },
        },
      },
    },
  },
}
