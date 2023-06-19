return {
	{
		"olimorris/onedarkpro.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("onedarkpro").setup({
				colors = {
					bg = "#000000",
					fg = "#abb2bf",
					red = "#ef596f",
					orange = "#d19a66",
					yellow = "#e5c07b",
					green = "#89ca78",
					cyan = "#2bbac5",
					blue = "#61afef",
					purple = "#d55fde",
					white = "#abb2bf",
					black = "#000000",
					gray = "#434852",
					highlight = "#e2be7d",
					comment = "#7f848e",
					none = "NONE",
				},
				options = {
					transparency = true,
				},
			})
			vim.cmd("colorscheme onedark_dark")
		end,
	},

	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			{ "neovim/nvim-lspconfig" },

			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-nvim-lsp" },

			{ "L3MON4D3/LuaSnip" },
		},
	},

	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		config = function()
			require("chatgpt").setup({
				api_key_cmd = "pass show api/chatgpt-apikey",
			})
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
	},

	{ "raichoo/purescript-vim" },
	{ "vmchale/dhall-vim" },
	{ "elixir-lang/vim-elixir" },
	--	{ "xiyaowong/transparent.nvim" },
	{ "williamboman/mason.nvim", enabled = false },
	{ "williamboman/mason-lspconfig.nvim", enabled = false },
	{ "jay-babu/mason-nvim-dap.nvim", enabled = false },
	{ "catppuccin/nvim", enabled = false },
}
