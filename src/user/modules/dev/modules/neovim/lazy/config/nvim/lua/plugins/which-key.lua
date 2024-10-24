return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>l", ":Lazy<CR>", desc = "Lazy" },
        { "<leader>t",
          function()
            vim.cmd("botright new | setlocal nonumber norelativenumber | resize 10 | terminal")
            vim.cmd("startinsert")
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
        { "<leader>bd", ":bd<CR>", desc = "Delete Buffer" },
        { "<leader>bD", "execute 'close'<CR> | <cmd>execute 'bd!'", desc = "Delete Window & Buffer" },

        { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action" },
        { "<leader>cr", vim.lsp.buf.rename, desc = "Rename Variable" },

        { "<leader>G", group = "Git"},
        { "<leader>f", group = "Files"},
        { "<leader>c", group = "Code"},
        { "<leader>g", group = "Goto"},
      },
    },
	}
}
