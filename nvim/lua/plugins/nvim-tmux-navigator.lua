return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<C-h>", "<Cmd>TmuxNavigateLeft<CR>" },
    { "<C-j>", "<Cmd>TmuxNavigateDown<CR>" },
    { "<C-k>", "<Cmd>TmuxNavigateUp<CR>" },
    { "<C-l>", "<Cmd>TmuxNavigateRight<CR>" },
    { "<C-\\>", "<Cmd>TmuxNavigatePrevious<CR>" },
  },
  lazy = true
}

