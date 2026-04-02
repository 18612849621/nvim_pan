return {
  { "projekt0n/github-nvim-theme", lazy = false, priority = 1000,
    config = function()
      vim.cmd("colorscheme github_light")
      -- 白色主题下光标加深，确保清晰可见
      vim.api.nvim_set_hl(0, "Cursor",      { fg = "#ffffff", bg = "#0969da" })
      vim.api.nvim_set_hl(0, "CursorLine",  { bg = "#eaeef2" })
      vim.api.nvim_set_hl(0, "CursorLineNr",{ fg = "#0969da", bold = true })
    end,
  },
}
