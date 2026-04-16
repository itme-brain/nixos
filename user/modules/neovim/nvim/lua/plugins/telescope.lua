local function get_root()
  local result = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }):wait()
  if result.code == 0 and result.stdout then
    local git_dir = vim.trim(result.stdout)
    if git_dir ~= "" then
      return git_dir
    end
  end

  return vim.fn.getcwd()
end

return {
  {
    "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-tree/nvim-web-devicons' }
    },
    config = function()
      -- Custom Telescope command to grep from Git root
      require("which-key").add({
        { "<leader>/", function()
            require('telescope.builtin').live_grep({ cwd = get_root() })
          end,
          desc = "grep" },
        { "<leader>ff", function()
            require('telescope.builtin').find_files({ cwd = get_root() })
          end,
          desc = "Search for Files" },
        { "<leader>fp", ":Telescope oldfiles<CR>", desc = "Oldfiles" },
        { "<leader>?", ":Telescope command_history<CR>", desc = "Command History" },
        { "<leader>cm", ":Telescope man_pages<CR>", desc = "Manpages" },

        -- Code
        { "gd",
          function()
            local attached = vim.lsp.get_clients({ bufnr = 0 })
            if next(attached) ~= nil then
              require('telescope.builtin').lsp_definitions()
            else
              vim.api.nvim_feedkeys("gd", "n", false)
            end
          end,
          mode = "n",
          desc = "Go to Definition"
        },
        { "<leader>gd", ":Telescope lsp_definitions<CR>", desc = "Go to Definition" },
        { "<leader>gr", ":Telescope lsp_references<CR>", desc = "Goto References" },
        { "<leader>gi", ":Telescope lsp_implementations<CR>", desc = "Go to Implementations" },
        { "<leader>gt", ":Telescope lsp_type_definitions<CR>", desc = "Go to Type Definition" },
        { "<leader>cv", ":Telescope treesitter<CR>", desc = "Function Names & Variables" },
        { "<leader>cd", ":Telescope diagnostics<CR>", desc = "Code Diagnostics" },

        -- Git
        { "<leader>Gt", ":Telescope git_branches<CR>", desc = "Git Branches" },
        { "<leader>Gc", ":Telescope git_commits<CR>", desc = "Git Commits" },
      })
    end
  }
}
