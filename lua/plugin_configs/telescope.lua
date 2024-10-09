local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- 定义一个函数用于搜索选中的单词去做全句查找
function SearchWordUnderCursor()
    local word = vim.fn.expand("<cword>")
    builtin.live_grep({ default_text = word })
end

function SearchFileWordUnderCursor()
    local word = vim.fn.expand("<cword>")
    builtin.find_files({ default_text = word })
end

vim.keymap.set('n', '<leader>ffg', ':lua SearchWordUnderCursor()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fff', ':lua SearchFileWordUnderCursor()<CR>', { noremap = true, silent = true })
