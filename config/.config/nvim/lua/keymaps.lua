-- --  next tab
-- vim.keymap.set('n', '<C-Tab>', ':tabnext<CR>')

-- -- previous tab
-- vim.keymap.set('n', '<C-S-Tab>', ':tabprev<CR>')

-- -- new tab
-- vim.keymap.set('n', '<D-t>', ':tabnew<CR>')

-- --  undo
-- vim.keymap.set('n', '<D-z>', ':undo<CR>')

-- --  redo
-- vim.keymap.set('n', '<D-S-z>', ':redo<CR>')

-- --  for save
-- vim.keymap.set('n', '<D-s>', ':w<CR>')

-- --  telescope
-- vim.keymap.set('n', '<D-p>', ':Telescope find_files<CR>')

local builtin = require("telescope.builtin")

vim.keymap.set('n', '<D-p>', builtin.find_files, {})
