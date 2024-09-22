-- Keep cursor centered while navigating document
vim.keymap.set("n", "<C-U>", "<C-U>zz", { silent = true })
vim.keymap.set("n", "<C-D>", "<C-D>zz", { silent = true })

-- Remap Ctrl + J/K/H/L to navigate between windows
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true, silent = true })

vim.keymap.set('n', '<C-Right>', ':vertical resize +10<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Left>', ':vertical resize -10<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Up>',   ':horizontal resize +10<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Down>', ':horizontal resize -10<CR>', { noremap = true, silent = true })

-- Remap Shift + H/L to switch between buffers
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<S-l>', ':bnext<CR>', { noremap = true, silent = true })

vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

vim.keymap.set("n", "<Esc>", ':nohlsearch<Bar>let @/=""<CR>', { noremap = true, silent = true})
