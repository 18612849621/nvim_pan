-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)
-- nvim-tree
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
vim.keymap.set('n', '<leader>c', ':%s/', opts)

--jq
vim.keymap.set('n', '<leader>jq', ':%!jq \'.\'<CR>', opts)

-- bufferline
-- 切换到下一个 buffer
vim.keymap.set('n', '<leader>bn', ':BufferLineCycleNext<CR>', opts)

-- 切换到上一个 buffer
vim.keymap.set('n', '<leader>bp', ':BufferLineCyclePrev<CR>', opts)

-- 关闭当前 buffer
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', opts)

-- 选中某一个buffer
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, ':BufferLineGoToBuffer ' .. i .. '<CR>', opts)
end

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

