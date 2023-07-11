-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-U>", "<C-U>zz", { silent = true })
vim.keymap.set("n", "<C-D>", "<C-D>zz", { silent = true })
vim.keymap.set("n", "H", ":bprev<CR>", { silent = true })
vim.keymap.set("n", "L", ":bnext<CR>", { silent = true })
vim.keymap.set(
	"n",
	"<leader>t",
	"<cmd>:new | setlocal nonumber norelativenumber | resize 10 | terminal<CR>",
	{ noremap = true, silent = true }
)
