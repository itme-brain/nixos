local servers = {
	"tsserver",
	"pyright",
	"nil_ls",
	"cssls",
	"html",
	"lua_ls",
	"marksman",
	"tailwindcss",
	"bashls",
  "clangd",
  "jsonls",
  "vuels"
  --"arduino-language-server"
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup ({
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
        highlight = {
          enable = true,
        }
      })
    end
  },

  {
    "m4xshen/autoclose.nvim",
    config = function ()
      require("autoclose").setup()
    end
  },

	--{
	--	"nvim-treesitter/nvim-treesitter-context",
  --  dependencies = { "nvim-treesitter/nvim-treesitter" },
	--	config = function()
	--		require("treesitter-context").setup({
	--			enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
	--			max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
	--			min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
	--			line_numbers = false,
	--			multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
	--			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
	--			mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
	--			-- Separator between context and content. Should be a single character string, like '-'.
	--			-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
	--			separator = "=",
	--			zindex = 20, -- The Z-index of the context window
	--			on_attach = nil, -- (fun(buf: integer): boolean) rurn false to disable attaching
	--		})
	--	end,
	--},

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
    config = function ()
      local lsp = require('lsp-zero').preset({})
      lsp.setup_servers(servers)
      lsp.setup()
    end
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp"
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

        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)

          end
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm(),
          ["<CR>"] = cmp.mapping(function(fallback)
            fallback()
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' }
        }),
      })
    end
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local lsp = require('lspconfig')
      local navic = require('nvim-navic')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      for _, server in ipairs(servers) do
        lsp[server].setup {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
              navic.attach(client,bufnr)
            end
          end,
        }
      end
      lsp.lua_ls.setup{
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      }
      require("which-key").add({
        { "<leader>cl", ":LspInfo<CR>", desc = "LSP Info" },
      })
    end
  },
}
