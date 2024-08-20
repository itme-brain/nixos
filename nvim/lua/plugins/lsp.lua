return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "lua",
          "c",
          "cpp",
          "python",
          "nix",
          "rust",
          "bash",
          "markdown",
          "html",
          "javascript",
          "css",

          "vim",

          "git_config",
          "git_rebase",
          "gitattributes",
          "gitcommit",
          "gitignore"
        },
        auto_install = true,
        sync_install = true,
        ignore_install = {},
      }
    end
  },

	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = false,
				multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
				trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- Separator between context and content. Should be a single character string, like '-'.
				-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
				separator = "=",
				zindex = 20, -- The Z-index of the context window
				on_attach = nil, -- (fun(buf: integer): boolean) rurn false to disable attaching
			})
      vim.cmd([[
        hi TreesitterContext guibg=NONE ctermbg=NONE
      ]])
		end,
	},

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("which-key").add({
        { "<leader>cl", ":LspInfo<CR>", desc = "LSP Info" },
      })
    end
  },

  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },

  {
	"hrsh7th/nvim-cmp",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
		}
  },
	config = function()
		local cmp = require("cmp")
		cmp.setup({
			enabled = function()
			  local context = require("cmp.config.context")
			  if vim.api.nvim_get_mode().mode == "c" then
			  return true
			  else
			    return not context.in_treesitter_capture("comment") and not context.in_syntax_group("comment")
			  end
			end,
			mapping = {
			  ["<C-p>"] = cmp.mapping.select_prev_item(),
			  ["<C-n>"] = cmp.mapping.select_next_item(),
			  ["<C-d>"] = cmp.mapping.scroll_docs(-4),
			  ["<C-f>"] = cmp.mapping.scroll_docs(4),
			  ["<C-e>"] = cmp.mapping.abort(),
			  ["<C-y>"] = cmp.mapping.confirm(),
			  ["<CR>"] = cmp.mapping(function(fallback)
			    fallback()
			  end, { "i", "s" }),
			}
		})
	end
  },
}
