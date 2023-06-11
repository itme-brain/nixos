return {
	--	{
	--		"projekt0n/github-nvim-theme",
	--		lazy = false, -- make sure we load this during startup if it is your main colorscheme
	--		priority = 1000, -- make sure to load this before all the other start plugins
	--		config = function()
	--			require("github-theme").setup({
	--				options = {
	--					transparent = true,
	--				},
	--			})
	--			vim.cmd("colorscheme github_dark_high_contrast")
	--		end,
	--	},

	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				opts = {
					color_overrides = {
						mocha = {
							base = "#000000",
							mantle = "#000000",
							crust = "#000000",
						},
					},
				},
			})
			vim.cmd("colorscheme catppuccin-mocha")
		end,
	},

	{ "williamboman/mason.nvim", enabled = false },
	{ "williamboman/mason-lspconfig.nvim", enabled = false }, -- Optional

	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" }, -- Required
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-nvim-lsp" }, -- Required

			{ "L3MON4D3/LuaSnip" }, -- Required
		},
	},

	{ "raichoo/purescript-vim" },
	{ "vmchale/dhall-vim" },
	{ "elixir-lang/vim-elixir" },
	{ "xiyaowong/transparent.nvim" },

	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		config = function()
			require("chatgpt").setup({
				api_key_cmd = "gpg --decrypt ~/Documents/tools/chatgpt-apikey.gpg 2>/dev/null",
			})
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
	},
}
