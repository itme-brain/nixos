-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

require("which-key").add({
  { "<leader>wd", "<cmd>bd<CR> | close<CR>", mode = "n", desc = "Delete window & buffer" },
  { "<leader>wD", "<cmd>close<CR>", mode = "n", desc = "Delete window" },
  { "<leader>t", "<cmd>:new | setlocal nonumber norelativenumber | resize 10 | terminal<CR>", mode = "n", desc = "Open Terminal" }
})

require("lualine").setup({
  options = {
    theme = 'iceberg_dark'
  }
})

local lsp = require("lsp-zero").preset({})
local cmp_nvim_lsp = require "cmp_nvim_lsp"
local cmp = require("cmp")

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
lsp.setup_servers({
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
})
lsp.setup()

require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
require("lspconfig").clangd.setup {
  capabilities = cmp_nvim_lsp.default_capabilities(),
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
}
require("lspconfig").nil_ls.setup {
  settings = {
    ["nil"] = {
      nix = {
        flake = {
          autoArchive = true,
        }
      }
    }
  }
}

cmp.setup({
	enabled = function()
		-- disable completion in comments
		local context = require("cmp.config.context")
		-- keep command mode completion enabled when cursor is in a comment
		if vim.api.nvim_get_mode().mode == "c" then
			return true
		else
			return not context.in_treesitter_capture("comment") and not context.in_syntax_group("comment")
		end
	end,
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		-- other sources...
	},
	formatting = {
		format = function(entry, vim_item)
			vim_item.menu = ""
			return vim_item
		end,
	},
	mapping = {
    -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings
    ["<C-p>"] = cmp.mapping.select_next_item(),
    ["<C-n>"] = cmp.mapping.select_prev_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-y>"] = cmp.mapping.confirm(),
		["<CR>"] = cmp.mapping(function(fallback)
			fallback()
		end, { "i", "s" }),
	},
})

--local dap = require("dap")
--dap.adapters.haskell = {
--	type = "executable",
--	command = "haskell-debug-adapter",
--	args = { "--hackage-version=0.0.33.0" },
--}
--dap.configurations.haskell = {
--	{
--		type = "haskell",
--		request = "launch",
--		name = "Debug",
--		workspace = "${workspaceFolder}",
--		startup = "${file}",
--		stopOnEntry = true,
--		logFile = vim.fn.stdpath("data") .. "/haskell-dap.log",
--		logLevel = "WARNING",
--		ghciEnv = vim.empty_dict(),
--		ghciPrompt = "λ: ",
--		-- Adjust the prompt to the prompt you see when you invoke the ghci command below
--		ghciInitialPrompt = "λ: ",
--		ghciCmd = "stack ghci --test --no-load --no-build --main-is TARGET --ghci-options -fprint-evld-with-show",
--	},
--}
