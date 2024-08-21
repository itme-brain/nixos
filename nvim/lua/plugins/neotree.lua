return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				window = {
					position = "left",
					width = 20,
				},
				--filesystem = {
				--  hijack_netrw_behavior = "disabled",
				--},
			})

			local function toggle_neotree()
				local api = vim.api
				local win = api.nvim_get_current_win()
				local bufs = api.nvim_list_bufs()

				for _, buf in ipairs(bufs) do
					local name = api.nvim_buf_get_name(buf)
					if name:match("neo%-tree filesystem") then
						api.nvim_command(":Neotree close")
						return
					end
				end

				api.nvim_command(":Neotree")
			end

      require("which-key").add({
        { "<leader>e", toggle_neotree, desc = "File Explorer" }
      })

      vim.fn.sign_define("DiagnosticSignError",
        {text = " ", texthl = "DiagnosticSignError"})
      vim.fn.sign_define("DiagnosticSignWarn",
        {text = " ", texthl = "DiagnosticSignWarn"})
      vim.fn.sign_define("DiagnosticSignInfo",
        {text = " ", texthl = "DiagnosticSignInfo"})
      vim.fn.sign_define("DiagnosticSignHint",
        {text = "󰌵", texthl = "DiagnosticSignHint"})
		end,
	},
}
