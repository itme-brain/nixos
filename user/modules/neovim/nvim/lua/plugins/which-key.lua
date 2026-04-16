return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>l", ":Lazy<CR>", desc = "Lazy" },
        { "<leader>t",
          function()
            vim.cmd.botright("new")
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.cmd.resize(10)
            vim.cmd.terminal()
            vim.cmd.startinsert()
          end,
          mode = "n",
          desc = "Open Terminal"
        },

        --{ "<leader>wd", "<cmd>execute 'bd' | execute 'close'<CR>", desc = "Delete window & buffer" },
        -- Window & Buffer Management
        { "<leader>w", group = "Windows"},
        { "<leader>wc", ":close<CR>", desc = "Close Window" },
        { "<leader>ws", ":split<CR>", desc = "Horizontal Window Split" },
        { "<leader>wv", ":vsplit<CR>", desc = "Vertial Window Split" },
        { "<leader>wm", "<C-w>_", desc = "Maximize Window" },

        { "<leader>b", group = "Buffers"},
        { "<leader>bd", function()
            local function is_neotree(bufnr)
              return vim.bo[bufnr].filetype == "neo-tree"
            end

            local current_buf = vim.api.nvim_get_current_buf()

            -- Skip if in neo-tree
            if is_neotree(current_buf) then
              vim.notify("Cannot delete buffer from neo-tree", vim.log.levels.WARN)
              return
            end
            local buflisted = vim.fn.getbufinfo({ buflisted = 1 })
            -- Prevent deleting last buffer
            if #buflisted <= 1 then
              vim.notify("Cannot delete last buffer", vim.log.levels.WARN)
              return
            end
            vim.cmd.bprevious()
            vim.cmd.bdelete({ args = { tostring(current_buf) } })
            -- If we ended up in neo-tree, move back to a regular window
            local new_buf = vim.api.nvim_get_current_buf()
            if is_neotree(new_buf) then
              vim.cmd.wincmd("l")
            end
          end, desc = "Delete Buffer" },
        { "<leader>bD", function()
            local current_buf = vim.api.nvim_get_current_buf()
            local current_win = vim.api.nvim_get_current_win()

            if vim.bo[current_buf].filetype == "neo-tree" then
              vim.notify("Cannot delete neo-tree buffer", vim.log.levels.WARN)
              return
            end

            local wins = vim.fn.win_findbuf(current_buf)
            if #wins > 1 then
              vim.api.nvim_win_close(current_win, false)
            end

            if vim.api.nvim_buf_is_valid(current_buf) then
              vim.cmd('bdelete! ' .. current_buf)
            end
          end, desc = "Delete Window & Buffer" },

        { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
        { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Variable" },
        { "<leader>ch", vim.lsp.buf.hover, desc = "Hover Info" },
        { "<leader>ce", vim.diagnostic.open_float, desc = "Show Diagnostic" },
        { "]d", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
        { "[d", vim.diagnostic.goto_prev, desc = "Prev Diagnostic" },

        { "<leader>G", group = "Git"},
        { "<leader>f", group = "Files"},
        { "<leader>c", group = "Code"},
        { "<leader>g", group = "Goto"},
      },
    },
	}
}
