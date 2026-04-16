-- Neovim 0.11+ LSP configuration
-- Uses nvim-lspconfig for server definitions + vim.lsp.enable() API

-- Detect NixOS (Mason doesn't work on NixOS due to FHS issues)
local is_nixos = vim.fn.filereadable("/etc/NIXOS") == 1

-- Servers to ensure are installed via Mason (non-NixOS only)
-- On NixOS, install these via extraPackages or per-project devShells
local mason_ensure_installed = {
  "lua_ls",       -- Neovim config
  "nil_ls",       -- Nix (nixd not available in Mason)
  "bashls",       -- Shell scripts
  "jsonls",       -- JSON configs
  "html",         -- HTML
  "cssls",        -- CSS
  "marksman",     -- Markdown
  "taplo",        -- TOML
  "yamlls",       -- YAML
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup({
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
    config = function()
      require("autoclose").setup()
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
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
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

  -- Mason: portable LSP installer (disabled on NixOS where it doesn't work)
  {
    "williamboman/mason.nvim",
    enabled = not is_nixos,
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    enabled = not is_nixos,
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = mason_ensure_installed,
        automatic_installation = false,  -- Only install what's in ensure_installed
      })
    end
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require('lspconfig')

      -- Neovim 0.12 exposes built-in :lsp commands and skips lspconfig's legacy
      -- :Lsp* aliases. Recreate the old names so existing mappings keep working.
      if vim.fn.exists(':lsp') == 2 and vim.fn.exists(':LspStart') == 0 then
        vim.api.nvim_create_user_command('LspStart', function(info)
          vim.cmd('lsp enable ' .. table.concat(info.fargs, ' '))
        end, { nargs = '*' })

        vim.api.nvim_create_user_command('LspRestart', function(info)
          vim.cmd('lsp restart ' .. table.concat(info.fargs, ' '))
        end, { nargs = '*', bang = true })

        vim.api.nvim_create_user_command('LspStop', function(info)
          local suffix = info.bang and '!' or ''
          vim.cmd('lsp stop' .. suffix .. ' ' .. table.concat(info.fargs, ' '))
        end, { nargs = '*', bang = true })
      end

      -- Diagnostic display configuration
      vim.diagnostic.config({
        virtual_text = {
          prefix = '●',
          spacing = 2,
          current_line = true;
        },
        float = {
          border = 'rounded',
          source = true,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.INFO] = '',
            [vim.diagnostic.severity.HINT] = '',
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Add border to hover and signature help windows.
      local hover_handler = vim.lsp.handlers.hover
      vim.lsp.handlers['textDocument/hover'] = function(err, result, ctx, config)
        return hover_handler(err, result, ctx, vim.tbl_extend('force', config or {}, {
          border = 'rounded',
        }))
      end

      local signature_help_handler = vim.lsp.handlers.signature_help
      vim.lsp.handlers['textDocument/signatureHelp'] = function(err, result, ctx, config)
        return signature_help_handler(err, result, ctx, vim.tbl_extend('force', config or {}, {
          border = 'rounded',
        }))
      end

      -- Get all known server names by scanning lspconfig's lsp directory
      local function get_all_servers()
        local servers = {}
        local lsp_path = vim.fn.stdpath('data') .. '/lazy/nvim-lspconfig/lsp'
        local files = vim.fn.readdir(lsp_path, function(name)
          return name:sub(-4) == '.lua'
        end)
        for _, file in ipairs(files) do
          local server = file:sub(1, -5)
          table.insert(servers, server)
        end
        return servers
      end

      local all_servers = get_all_servers()

      -- local navic = require('nvim-navic')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Global config applied to all servers
      vim.lsp.config('*', {
        autostart = false,  -- Don't auto-attach, use <leader>css to start manually
        capabilities = capabilities,
        -- on_attach = function(client, bufnr)
        --   if client.server_capabilities.documentSymbolProvider then
        --     navic.attach(client, bufnr)
        --   end
        -- end,
      })

      -- Server-specific settings (merged with lspconfig defaults)
      vim.lsp.config.lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      }

      -- Check if server binary is available
      local function is_server_installed(config)
        if config.default_config and config.default_config.cmd then
          local cmd = config.default_config.cmd[1]
          return vim.fn.executable(cmd) == 1
        end
        return false
      end

      -- Find and start LSP server(s) for current filetype
      local function lsp_start_smart()
        local ft = vim.bo.filetype
        if ft == '' then
          vim.notify("No filetype detected", vim.log.levels.WARN)
          return
        end

        -- Find all matching servers (filetype match + binary installed)
        local matching = {}
        for _, server in ipairs(all_servers) do
          local ok, config = pcall(require, 'lspconfig.configs.' .. server)
          if ok and config.default_config and config.default_config.filetypes then
            if vim.tbl_contains(config.default_config.filetypes, ft) and is_server_installed(config) then
              table.insert(matching, server)
            end
          end
        end

        -- Sort for consistent ordering
        table.sort(matching)

        local function start_server(server)
          vim.lsp.enable(server)
        end

        if #matching == 0 then
          vim.notify("No LSP server installed for filetype: " .. ft, vim.log.levels.WARN)
        elseif #matching == 1 then
          start_server(matching[1])
        else
          vim.ui.select(matching, {
            prompt = "Select LSP server:",
          }, function(choice)
            if choice then
              start_server(choice)
            end
          end)
        end
      end

      -- LSP keybindings
      require("which-key").add({
        { "<leader>cs",  group = "LSP Commands" },
        { "<leader>cf",  function() vim.lsp.buf.format() end, desc = "Code Format" },
        { "<leader>csi", ":checkhealth vim.lsp<CR>",          desc = "LSP Info" },
        { "<leader>csr", ":lsp restart<CR>",                  desc = "LSP Restart" },
        { "<leader>css", lsp_start_smart,                     desc = "LSP Start" },
        { "<leader>csx", ":lsp stop<CR>",                     desc = "LSP Stop" },
      })
    end
  },

  {
    "taproot-wizards/bitcoin-script-hints.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("bitcoin-script-hints").setup()
    end
  }
}
