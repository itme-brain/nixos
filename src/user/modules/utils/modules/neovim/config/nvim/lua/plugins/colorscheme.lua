return {
	{
		"chriskempson/base16-vim",
		config = function()
			vim.cmd("colorscheme base16-onedark")
			vim.cmd([[
				hi Normal guibg=NONE ctermbg=NONE guifg=#FFFFFF
        hi Visual ctermbg=Gray ctermfg=Black guibg=Gray guifg=Black
				hi NonText guibg=NONE ctermbg=NONE
				hi LineNr guibg=NONE ctermbg=NONE
				hi CursorLine guibg=NONE ctermbg=NONE
				hi CursorLineNr guibg=NONE ctermbg=NONE guifg=#E5C07B ctermfg=Yellow cterm=bold
        hi Search ctermfg=Black guifg=#000000 ctermbg=Gray guibg=#FFCC66
        hi Pmenu ctermbg=Black ctermfg=White cterm=NONE guibg=Black guifg=White gui=NONE
        hi PmenuSel ctermbg=Green ctermfg=Black cterm=NONE guibg=Green guifg=Black gui=NONE
        hi PmenuThumb ctermbg=Green guibg=Green
        hi PmenuSbar ctermbg=Black guibg=Black
        hi WinSeparator guibg=NONE ctermbg=NONE

				hi GitGutterChange guibg=NONE ctermbg=NONE
				hi GitGutterAdd guibg=NONE ctermbg=NONE
				hi GitGutterDelete guibg=NONE ctermbg=NONE
        hi SignColumn ctermbg=NONE guibg=NONE

        hi TelescopeSelection guibg=Gray guifg=Green gui=bold ctermbg=Black ctermfg=Green cterm=bold
        hi TelescopePreviewMatch ctermbg=Yellow ctermfg=Black guibg=Yellow guifg=Black

        hi TreesitterContext guibg=NONE ctermbg=NONE

        hi LazyH1 ctermbg=Green ctermfg=Black guibg=Black guifg=Green
        hi IblScope guibg=NONE guifg=Yellow ctermbg=NONE ctermfg=Yellow
        
        hi ConflictMarker ctermfg=red guifg=red
        match ConflictMarker /<<<<<<< HEAD\|=======\|>>>>>>> .\+/

        hi DiffAdd ctermbg=none guibg=none
        hi DiffChange ctermbg=none guibg=none
        hi DiffDelete ctermbg=none guibg=none
        hi DiffText ctermbg=none guibg=none
			]])

      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.cmd("highlight YankHighlight ctermbg=yellow ctermfg=black guibg=yellow guifg=black")
          vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 150 })
        end,
      })
		end,
	},

  {
    "fei6409/log-highlight.nvim"
  }

}
