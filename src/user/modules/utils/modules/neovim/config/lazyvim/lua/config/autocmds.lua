-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.g.autoformat = false
vim.cmd([[
  au BufRead,BufNewFile *.purs set filetype=purescript
]])

require("which-key").register({
  w = {
    d = {
      "<cmd>bd<CR> | close<CR>",
      "Delete window and buffer"
    },
    D = {
      "<cmd>close<CR>",
      "Delete window only",
    },
  },
	t = {
		"<cmd>:new | setlocal nonumber norelativenumber | resize 10 | set winfixheight | terminal<CR>",
		"Open Terminal",
	},
}, {
	prefix = "<leader>",
})

require("notify").setup({
	background_colour = "#000000",
})

local lsp = require("lsp-zero").preset({})

--require("null-ls").setup({
--	-- you can reuse a shared lspconfig on_attach callback here
--	on_attach = function(client, bufnr)
--		if client.supports_method("textDocument/formatting") then
--			vim.api.nvim_clear_autocmds({ group = vim.api.nvim_create_augroup("LspFormatting", {}), buffer = bufnr })
--			vim.api.nvim_create_autocmd("BufWritePre", {
--				group = augroup,
--				buffer = bufnr,
--				callback = function()
--					vim.lsp.buf.format({
--						bufnr = bufnr,
--						filter = function(client)
--							return client.name == "null-ls"
--						end,
--					})
--					vim.lsp.buf.formatting_sync()
--				end,
--			})
--		end
--	end,
--})

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
})

require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

local cmp_nvim_lsp = require "cmp_nvim_lsp"

require("lspconfig").clangd.setup {
  capabilities = cmp_nvim_lsp.default_capabilities(),
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
}

require("lspconfig").cssls.setup {
  settings = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    scss = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    less = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
  }
}

--require("lspconfig").volar.setup({
--	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
--})

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

local cmp = require("cmp")
cmp.setup({
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
	-- other configurations...
})

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
	mapping = {
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
--	["<Down>"] = cmp.mapping.select_next_item(),
--	["<Up>"] = cmp.mapping.select_prev_item(),
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif cmp.completed then
				cmp.confirm({ select = true })
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),

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
