-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local mirror = vim.env.GITHUB_MIRROR or "https://github.com"
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    mirror .. "/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local mirror = vim.env.GITHUB_MIRROR or "https://github.com"

require("lazy").setup("plugins", {
  change_detection = { notify = false },
  git = {
    -- 所有插件 git clone 时替换 github.com
    url_format = mirror .. "/%s.git",
  },
})

require("config.keymaps")
