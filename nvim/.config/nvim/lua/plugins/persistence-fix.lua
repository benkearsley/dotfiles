-- Fix persistence.nvim causing shutdown issues
return {
  {
    "folke/persistence.nvim",
    opts = {
      -- Reduce session save frequency to avoid race conditions
      options = { "buffers", "curdir", "tabpages", "winsize" },
      
      -- Don't auto-save on exit (this causes race conditions!)
      pre_save = nil,
      
      -- Only save session when explicitly called
      save_on_exit = false, -- THIS IS KEY!
    },
  },
}
