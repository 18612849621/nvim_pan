return {
  { "nvim-lualine/lualine.nvim",
    opts = { options = { theme = "auto", icons_enabled = false } },
  },

  { "akinsho/bufferline.nvim",
    opts = { options = { show_buffer_icons = false } },
  },

  { "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
}
