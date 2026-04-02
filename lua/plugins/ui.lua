return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  { "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "github_light" } },
  },

  { "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  { "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
}
