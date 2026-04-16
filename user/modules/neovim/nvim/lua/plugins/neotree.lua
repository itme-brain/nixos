return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
        enable_diagnostics = false,
				default_component_configs = {
					git_status = {
						symbols = {
							added     = "+",
							modified  = "~",
							deleted   = "-",
							renamed   = ">",
							untracked = "?",
							ignored   = "!",
							unstaged  = "U",
							staged    = "S",
							conflict  = "C",
						},
					},
				},
				window = {
					position = "left",
					width = 20,
				},
				event_handlers = {
					{
						event = "neo_tree_window_after_open",
						handler = function()
							local win = vim.api.nvim_get_current_win()
							vim.wo[win].winfixwidth = true
							vim.wo[win].winfixbuf = true
							vim.wo[win].cursorline = true
						end
					},
				},
			})

			-- Keep the selected entry readable without a solid row background.
			vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "NONE", fg = "#a6e3a1" })

			-- Apply highlight and re-apply on colorscheme change
			vim.api.nvim_create_autocmd({ "FileType", "ColorScheme" }, {
				pattern = { "neo-tree", "*" },
				callback = function(ev)
					if ev.event == "ColorScheme" then
						vim.api.nvim_set_hl(0, "NeoTreeCursorLine", { bg = "NONE", fg = "#a6e3a1" })
					end
					local win = vim.api.nvim_get_current_win()
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype == "neo-tree" then
						vim.wo[win].winhighlight = "CursorLine:NeoTreeCursorLine"
					end
				end,
			})

			-- Lock cursor to leftmost column in neo-tree
			vim.api.nvim_create_autocmd("CursorMoved", {
				pattern = "neo-tree*",
				callback = function()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					if col ~= 0 then
						vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], 0 })
					end
				end,
			})

			local function toggle_neotree()
				local api = vim.api
				local bufs = api.nvim_list_bufs()

				for _, buf in ipairs(bufs) do
					local name = api.nvim_buf_get_name(buf)
					if name:match("neo%-tree filesystem") then
						vim.cmd("Neotree close")
						return
					end
				end

				vim.cmd("Neotree")
			end

      require("which-key").add({
        { "<leader>e", toggle_neotree, desc = "File Explorer" }
      })

      --vim.fn.sign_define("DiagnosticSignError",
      --  {text = " ", texthl = "DiagnosticSignError"})
      --vim.fn.sign_define("DiagnosticSignWarn",
      --  {text = " ", texthl = "DiagnosticSignWarn"})
      --vim.fn.sign_define("DiagnosticSignInfo",
      --  {text = " ", texthl = "DiagnosticSignInfo"})
      --vim.fn.sign_define("DiagnosticSignHint",
      --  {text = "󰌵", texthl = "DiagnosticSignHint"})
		end,
	},
}
