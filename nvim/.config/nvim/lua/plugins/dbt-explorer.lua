return {
  dir = "/Users/b0k07eo/projects/dbt-nvim-extension",
  name = "dbt-explorer",
  dependencies = {
    "nvim-telescope/telescope.nvim", -- LazyVim includes this
  },
  ft = "sql", -- Lazy load on SQL files
  cmd = { "DbtExplorer", "DbtExplorerTelescope", "DbtExplorerRefresh" },
  keys = {
    { "<leader>De", "<cmd>DbtExplorer<cr>", desc = "dbt Explorer" },
    { "<leader>DE", "<cmd>DbtExplorerTelescope<cr>", desc = "dbt Explorer (Telescope)" },
  },
  config = function()
    require("dbt-explorer").setup({
      keymaps = {
        open_explorer = "<leader>De",
        open_with_picker = "<leader>DE",
      },
    })
  end,
}
