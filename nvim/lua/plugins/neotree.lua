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
      require("which-key").add({
        { "<leader>e", ":Neotree<CR>", desc = "Neotree" }
      })
		end,
	},
}
