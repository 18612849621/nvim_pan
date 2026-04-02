return {
  { "nvim-treesitter/nvim-treesitter", tag = "v0.9.3",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "nasm", "c", "python", "cpp", "proto", "bash", "cuda", "yaml", "json", "json5" },
      sync_install = false,
      auto_install = true,
      ignore_install = { "javascript" },
      highlight = {
        enable = true,
        disable = function(_, buf)
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > 100 * 1024 then return true end
        end,
        additional_vim_regex_highlighting = false,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
