-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<C-K>", "<C-U>zz", { silent = true })
vim.keymap.set("n", "<C-J>", "<C-D>zz", { silent = true })
vim.keymap.set("n", "<C-L>", "w", { silent = true })
vim.keymap.set("n", "<C-H>", "b", { silent = true })
