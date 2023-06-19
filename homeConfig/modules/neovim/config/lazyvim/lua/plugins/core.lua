return {
	{
		"projekt0n/github-nvim-theme",
		lazy = false,
		priority = 1000,
		config = function()
			require("github-theme").setup({
				options = {
					transparent = true,
				},
				styles = { -- Style to be applied to different syntax groups
					comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
					functions = "italic",
					keywords = "bold",
					variables = "NONE",
					conditionals = "NONE",
					constants = "NONE",
					numbers = "NONE",
					operators = "NONE",
					strings = "NONE",
					types = "NONE",
				},
				darken = { -- Darken floating windows and sidebar-like windows
					floats = true,
					sidebars = {
						enable = true,
						list = {}, -- Apply dark background to specific windows
					},
				},
			})
			vim.cmd("colorscheme github_dark")
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
