return {
	"nvim-neo-tree/neo-tree.nvim",
  	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
  	},
  	lazy = false, -- neo-tree will lazily load itself
	opts = {
	-- fill any relevant options here
	},
	config = function()
		local function toggle_or_focus_neotree()
			local neotree_win = nil

			-- Look for an existing Neo-tree window
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
				if filetype == "neo-tree" then
					neotree_win = win
					break
				end
			end

  			if neotree_win then
    				if vim.api.nvim_get_current_win() == neotree_win then
      					-- If we're *in* the Neo-tree window → close it
      					vim.cmd("Neotree close")
    				else
      					-- If we're elsewhere → focus Neo-tree window
      					vim.api.nvim_set_current_win(neotree_win)
    				end
  			else
    				-- If Neo-tree is not open → open it
    				vim.cmd("Neotree filesystem reveal left")
  			end
		end

		vim.keymap.set('n', '<C-n>', toggle_or_focus_neotree, { noremap = true, silent = true })
	end
}
