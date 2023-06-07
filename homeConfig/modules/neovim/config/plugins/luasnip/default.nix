{ pkgs, ... }:

with pkgs.vimPlugins;
[
  { plugin = luasnip; 
    config = ''
    lua << EOF
      local luasnip = require 'luasnip'

      -- Expand or jump in a snippet
      vim.api.nvim_set_keymap('i', '<Tab>', '<cmd>lua return luasnip.expand_or_jumpable() and \'<Plug>luasnip-expand-or-jump\' or \'<Tab>\'<CR>', { expr = true, silent = true })

      -- Jump backwards in a snippet
      vim.api.nvim_set_keymap('i', '<S-Tab>', '<cmd>lua luasnip.jump(-1)<CR>', {silent = true})

      -- Keymaps for Select mode
      vim.api.nvim_set_keymap('s', '<Tab>', '<cmd>lua require(\'luasnip\').jump(1)<CR>', {silent = true})
      vim.api.nvim_set_keymap('s', '<S-Tab>', '<cmd>lua require(\'luasnip\').jump(-1)<CR>', {silent = true})

      -- Changing choices in choiceNodes
      vim.api.nvim_set_keymap('i', '<C-E>', '<cmd>lua return luasnip.choice_active() and \'<Plug>luasnip-next-choice\' or \'<C-E>\'<CR>', { expr = true, silent = true })
      vim.api.nvim_set_keymap('s', '<C-E>', '<cmd>lua return luasnip.choice_active() and \'<Plug>luasnip-next-choice\' or \'<C-E>\'<CR>', { expr = true, silent = true })
    EOF
    '';
  }
]
