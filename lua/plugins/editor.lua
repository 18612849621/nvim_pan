return {
  { "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  { "nvim-telescope/telescope.nvim", tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>ffg', function()
        builtin.live_grep({ default_text = vim.fn.expand("<cword>") })
      end, { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>fff', function()
        builtin.find_files({ default_text = vim.fn.expand("<cword>") })
      end, { noremap = true, silent = true })
    end,
  },

  { "numToStr/Comment.nvim", opts = {} },
}
