''
let mapleader = " "
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
  \| endif

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf', { 'do': { -> fzf#install()  }  }
Plug 'junegunn/fzf.vim'
Plug 'mtdl9/vim-log-highlighting'

call plug#end()

let $FZF_DEFAULT_OPTS = '--bind=tab:down,shift-tab:up'
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

if empty(glob('~/.vim/plugged'))
  silent! :PlugInstall | q
endif
set number
set clipboard=unnamed,unnamedplus
set relativenumber
set relativenumber
set tabstop=2
set shiftwidth=2
set expandtab
set ignorecase
set noswapfile
colorscheme elflord

highlight Normal ctermbg=NONE guibg=NONE
highlight NormalNC ctermbg=NONE guibg=NONE

vnoremap < <gv
vnoremap > >gv
nnoremap <C-U> <C-U>zz
nnoremap <C-D> <C-D>zz
nnoremap <leader>f :FZF 
nnoremap <leader>/ :Rg<Space>
''
