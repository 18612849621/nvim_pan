local opts = { noremap = true, silent = true }

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- nvim-tree
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
vim.keymap.set('n', '<leader>c', ':%s/', opts)

-- jq
vim.keymap.set('n', '<leader>jq', ':%!jq \'.\'<CR>', opts)

-- bufferline
vim.keymap.set('n', '<leader>bn', ':BufferLineCycleNext<CR>', opts)
vim.keymap.set('n', '<leader>bp', ':BufferLineCyclePrev<CR>', opts)
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', opts)
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, ':BufferLineGoToBuffer ' .. i .. '<CR>', opts)
end

-- Visual indent
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Diagnostics
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, opts)
