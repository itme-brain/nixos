return {
  {
    "chriskempson/base16-vim",
    config = function()
      local color_group = vim.api.nvim_create_augroup("config_colorscheme", { clear = true })

      local highlights = {
        Normal = { bg = "NONE", fg = "#FFFFFF" },
        Visual = { bg = "Gray", fg = "Black" },
        NonText = { bg = "NONE" },
        LineNr = { bg = "NONE" },
        CursorLine = { bg = "NONE" },
        CursorLineNr = { bg = "NONE", fg = "#E5C07B", bold = true },
        Search = { bg = "#FFCC66", fg = "#000000" },
        Pmenu = { bg = "Black", fg = "White" },
        PmenuSel = { bg = "Green", fg = "Black" },
        PmenuThumb = { bg = "Green" },
        PmenuSbar = { bg = "Black" },
        WinSeparator = { bg = "NONE" },
        GitGutterChange = { bg = "NONE" },
        GitGutterAdd = { bg = "NONE" },
        GitGutterDelete = { bg = "NONE" },
        GitSignsAddNr = { bg = "NONE", fg = "#98c379" },
        GitSignsChangeNr = { bg = "NONE", fg = "#61afef" },
        GitSignsDeleteNr = { bg = "NONE", fg = "#e06c75" },
        SignColumn = { bg = "NONE" },
        NeoTreeGitAdded = { bg = "NONE", fg = "#98c379" },
        NeoTreeGitModified = { bg = "NONE", fg = "#e5c07b" },
        NeoTreeGitDeleted = { bg = "NONE", fg = "#e06c75" },
        NeoTreeGitConflict = { bg = "NONE", fg = "#e06c75" },
        NeoTreeGitUntracked = { bg = "NONE", fg = "#61afef" },
        TelescopeSelection = { bg = "Gray", fg = "Green", bold = true },
        TelescopePreviewMatch = { bg = "Yellow", fg = "Black" },
        TreesitterContext = { bg = "NONE" },
        LazyH1 = { bg = "Black", fg = "Green" },
        IblScope = { bg = "NONE", fg = "Yellow" },
        ConflictMarker = { fg = "red" },
        DiffAdd = { bg = "NONE" },
        DiffChange = { bg = "NONE" },
        DiffDelete = { bg = "NONE" },
        DiffText = { bg = "NONE" },
        BufferLineFill = { bg = "NONE" },
        BufferLineBackground = { bg = "NONE", fg = "#5c6370" },
        BufferLineBuffer = { bg = "NONE", fg = "#5c6370" },
        BufferLineBufferSelected = { bg = "NONE", fg = "#FFFFFF", bold = true },
        BufferLineBufferVisible = { bg = "NONE", fg = "#abb2bf" },
        BufferLineCloseButton = { bg = "NONE", fg = "#5c6370" },
        BufferLineCloseButtonSelected = { bg = "NONE", fg = "#e06c75" },
        BufferLineCloseButtonVisible = { bg = "NONE", fg = "#5c6370" },
        BufferLineModified = { bg = "NONE", fg = "#e5c07b" },
        BufferLineModifiedSelected = { bg = "NONE", fg = "#e5c07b" },
        BufferLineModifiedVisible = { bg = "NONE", fg = "#e5c07b" },
        BufferLineSeparator = { bg = "NONE", fg = "#3e4452" },
        BufferLineSeparatorSelected = { bg = "NONE", fg = "#3e4452" },
        BufferLineSeparatorVisible = { bg = "NONE", fg = "#3e4452" },
        BufferLineIndicatorSelected = { bg = "NONE", fg = "#61afef" },
        YankHighlight = { bg = "yellow", fg = "black" },
      }

      local function apply_highlights()
        for group, spec in pairs(highlights) do
          vim.api.nvim_set_hl(0, group, spec)
        end
      end

      local conflict_pattern = [[<<<<<<< HEAD\|=======\|>>>>>>> .\+]]
      local function apply_conflict_match(win)
        if vim.w[win].conflict_marker_match_id then
          pcall(vim.fn.matchdelete, vim.w[win].conflict_marker_match_id, win)
        end
        vim.w[win].conflict_marker_match_id = vim.fn.matchadd("ConflictMarker", conflict_pattern, 10, -1, {
          window = win,
        })
      end

      vim.cmd.colorscheme("base16-onedark")
      apply_highlights()

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = color_group,
        callback = apply_highlights,
      })

      vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
        group = color_group,
        callback = function(event)
          apply_conflict_match(vim.api.nvim_get_current_win())
        end,
      })

      vim.api.nvim_create_autocmd("TextYankPost", {
        group = color_group,
        callback = function()
          vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 150 })
        end,
      })
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "fei6409/log-highlight.nvim"
  }

}
