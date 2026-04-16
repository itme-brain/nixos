# Vim Config

Lightweight Vim config that mirrors the core editing feel of the Neovim setup without the IDE stack.

## Install

```bash
git clone git@github.com:itme-brain/vim.git ~/.vim
vim  # plugins auto-install on first run
```

Requires `curl` and `git` for vim-plug bootstrap. On NixOS this is managed via home-manager instead.

## How it works

- Vim auto-loads `~/.vim/vimrc` — no symlinks needed
- [vim-plug](https://github.com/junegunn/vim-plug) auto-downloads itself via curl on first run if missing
- Missing plugins are installed with `PlugInstall --sync` on `VimEnter`, then the vimrc is re-sourced
- `silent! colorscheme` suppresses errors if the colorscheme hasn't been fetched yet (e.g. offline first run)
- Undo history persists to `~/.vim/undodir` across sessions (`undofile`)

## Plugins

| Plugin | What it does |
|--------|-------------|
| base16-vim | Colorscheme (onedark) |
| vim-surround | Surround text objects (`cs"'`, `ysiw]`) |
| auto-pairs | Auto-close brackets/quotes |
| fzf + fzf.vim | Fuzzy finder (files, buffers, grep) |
| vim-log-highlighting | Syntax highlighting for log files |
| vim-highlightedyank | Flash feedback on yank |
| lightline.vim | Statusline |
| vim-anzu | Search match count in statusline |

## Keybinds

Leader is `Space`.

### File explorer & search
| Key | Action |
|-----|--------|
| `<leader>e` | Toggle netrw sidebar |
| `<leader>/` | Ripgrep search from git root |
| `<leader>ff` | Find files from git root (fzf) |
| `<leader>fp` | Recent files (fzf) |
| `<leader>fb` | Open buffers (fzf) |
| `<leader>?` | Command history (fzf) |

### Buffers
| Key | Action |
|-----|--------|
| `H` / `L` | Previous / next buffer |
| `<leader>bd` | Delete buffer safely |

### Windows
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate windows (skips netrw) |
| `<C-Arrow>` | Resize windows |
| `<leader>wc` | Close window |
| `<leader>ws` | Horizontal split |
| `<leader>wv` | Vertical split |
| `<leader>wm` | Maximize window |

### Other
| Key | Action |
|-----|--------|
| `<Esc>` | Clear search highlight |
| `<C-U>` / `<C-D>` | Scroll half-page (centered) |
| `<` / `>` (visual) | Indent and keep selection |
| `<leader>t` | Terminal (bottom split) |
| `<leader>ts` | Insert timestamp |
| `<leader>pu` | PlugUpdate |
| `<leader>pi` | PlugInstall |
