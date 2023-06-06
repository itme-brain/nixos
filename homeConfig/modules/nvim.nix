{ pkgs, lib, config, ... }:

with lib;
let 
  cfg = config.modules.neovim;

  github-theme = pkgs.vimUtils.buildVimPlugin {
    name = "github-theme";
    src = pkgs.fetchFromGithub {
      owner = "projekt0n";
      repo = "github-nvim-theme";
      rev = "ea713c37691b2519f56cd801a2330bdf66393d0f";
      sha256 = "0cwr3b5r2ac7aizxmwb3mlhdc2sh0pw670vcwps79x9jp52yrj2y";
    };
  };

  LSPs = with pkgs; [
    nil nixfmt marksman
    sumneko-lua-language-server stylua
    haskell-language-server hlint
  ];

  LSPs' = with pkgs.nodePackages; [
    vscode-langservers-extracted typescript-language-server eslint
    bash-language-server diagnostic-languageserver
    pyright purescript-language-server
  ];
  
in 
{ options.modules.neovim = { enable = mkEnableOption "neovim"; };
  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        {
          plugin = github-theme;
          config = '' 
          lua << EOF
            vim.cmd('colorscheme github_dark_high_contrast')
          EOF
          '';
        }

        { plugin = lazygit.nvim; }

        {
          plugin = LazyVim;
          config = '' 
          lua << EOF
            return {
              {'williamboman/mason.nvim', enabled = false },
              {'williamboman/mason-lspconfig.nvim', enabled = false },
              {'nvim-treesitter/nvim-treesitter', enabled = false },
            } 
          EOF
          '';
        }
        
        {
          plugin = lsp-zero-nvim;
          config = '' 
          lua << EOF
            branch = 'v2.x'
            requires = {
              {'neovim/nvim-lspconfig'},
              {'hrsh7th/nvim-cmp'},
              {'hrsh7th/cmp-nvim-lsp'},
              {'L3MON4D3/LuaSnip'},
            }
          '';
        }

        {
          plugin = nvim-treesitter.withAllGrammars;
          config = '' 
            lua << EOF
              require'nvim-treesitter.configs'.setup {
                highlight = {
                  enable = true,
                },
              }
            EOF
          '';
        }
      ];
      
      extraLuaConfig = ''
      lua << EOF
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true 

        vim.o.clipboard = "unnamedplus"
      EOF
      '';

      generatedConfigs = {
        lua = ''
          require("config.lazy")

          local lsp = require("lsp-zero").preset({})

          lsp.on_attach(function(client, bufnr)
            lsp.default_keymaps({ buffer = bufnr })
          end)

          lsp.setup_servers({
            "tsserver",
            "eslint",
            "hls",
            "pyright",
            "nil_ls",
            "cssls",
            "html",
            "jsonls",
            "diagnosticls",
            "lua_ls",
            "marksman",
            "purescriptls",
            "tailwindcss",
            "bashls",
          })

          require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

          lsp.setup()

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
            },
          })

          vim.cmd([[
            au BufRead,BufNewFile *.purs set filetype=purescript
          ]])

          local has_words_before = function()
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
          end

          local luasnip = require("luasnip")

          cmp.setup({
            enabled = function()
              -- disable completion in comments
              local context = require("cmp.config.context")
              -- keep command mode completion enabled when cursor is in a comment
              if vim.api.nvim_get_mode().mode == "c" then
                return true
              else
                return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
              end
            end,
            mapping = {
              ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
                -- they way you will only jump inside the snippet region
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                elseif has_words_before() then
                  cmp.complete()
                else
                  fallback()
                end
              end, { "i", "s" }),

              ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { "i", "s" }),

              ["<CR>"] = cmp.mapping({
                i = function(fallback)
                  if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                  else
                    fallback()
                  end
                end,
                s = cmp.mapping.confirm({ select = true }),
                c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
              }),
            },
          })

          vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            -- Disable virtual_text
            virtual_text = false,
          })

          require("notify").setup({
            background_colour = "#000000",
          })
        ''; 
      };

      extraPackages = LSPs ++ LSPs';
    };
  };
}
