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
			vim.cmd("colorscheme onedark")
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
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = false,
				multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
				trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- Separator between context and content. Should be a single character string, like '-'.
				-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
				separator = "-",
				zindex = 20, -- The Z-index of the context window
				on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
			})
		end,
	},

  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
      require("neo-tree").setup({
        window = {
          position = "left",
          width = 20,
        },
      })
    end,
  },

  { "NoahTheDuke/vim-just", ft = { "just" }, },
  { "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    --dependencies = { "rafamadriz/friendly-snippets" },
  },
  --{ "rafamadriz/friendly-snippets" },
	--[[
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
  --]]

	{ "williamboman/mason.nvim", enabled = false },
	{ "williamboman/mason-lspconfig.nvim", enabled = false },
	{ "jay-babu/mason-nvim-dap.nvim", enabled = false },
	{ "catppuccin/nvim", enabled = false },
  { "folke/flash.nvim", enabled = false }
}
