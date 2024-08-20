return {
	{
		"chriskempson/base16-vim",
		config = function()
			vim.cmd("colorscheme base16-onedark")
			vim.cmd([[
				hi Normal guibg=NONE ctermbg=NONE
				hi NonText guibg=NONE ctermbg=NONE
				hi LineNr guibg=NONE ctermbg=NONE
				hi CursorLine guibg=NONE ctermbg=NONE
				hi CursorLineNr guibg=NONE ctermbg=NONE guifg=#E5C07B ctermfg=Yellow cterm=bold
        hi Search ctermfg=Black guifg=#000000 ctermbg=Gray guibg=#FFCC66
        hi Pmenu ctermbg=Gray ctermfg=Black cterm=NONE guibg=Gray guifg=Black gui=NONE
        hi PmenuSel ctermbg=Black ctermfg=Green cterm=NONE guibg=Black guifg=Green gui=NONE
        hi PmenuThumb ctermbg=Green guibg=Green
        hi PmenuSbar ctermbg=Black guibg=Black
        hi WinSeparator guibg=NONE ctermbg=NONE

				hi GitGutterChange guibg=NONE ctermbg=NONE
				hi GitGutterAdd guibg=NONE ctermbg=NONE
				hi GitGutterDelete guibg=NONE ctermbg=NONE
        hi SignColumn ctermbg=NONE guibg=NONE

        hi TelescopeSelection guibg=Gray guifg=Green gui=bold ctermbg=Black ctermfg=Green cterm=bold
        hi TelescopePreviewMatch ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black
			]])

      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
        end,
      })
		end,
	}
}
