return {
  {
    "nvim-telescope/telescope.nvim",
    brach = '0.1.x',
    dependencies = {
      {
        'nvim-lua/plenary.nvim'
      },
      {
        'nvim-tree/nvim-web-devicons'
      }
    },
    config = function()
      require("which-key").add({
        { "<leader>/", ":Telescope live_grep<CR>", desc = "grep" },
        { "<leader>ff", ":Telescope fd<CR>", desc = "Search for Files" },
        { "<leader>fp", ":Telescope oldfiles<CR>", desc = "Oldfiles" },
        { "<leader>?", ":Telescope command_history<CR>", desc = "Command History" },
        { "<leader>cm", ":Telescope man_pages<CR>", desc = "Manpages" },

        -- Code
        { "<leader>gd", ":Telescope lsp_definitions<CR>", desc = "Go to Definition" },
        { "<leader>gi", ":Telescope lsp_implementations<CR>", desc = "Go to Implementations" },
        { "<leader>gt", ":Telescope lsp_type_definitions<CR>", desc = "Go to Type Definition" },
        { "<leader>cv", ":Telescope treesitter<CR>", desc = "List function names & variables" },
        { "<leader>ca", ":Telescope diagnostics<CR>", desc = "Code diagnostics" },

        -- Git
        { "<leader>Gt", ":Telescope git_branches<CR>", desc = "Git Branches" },
        { "<leader>Gc", ":Telescope git_commits<CR>", desc = "Git Commits" },
      })
    end
  }
}
