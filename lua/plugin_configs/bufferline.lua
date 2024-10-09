vim.opt.termguicolors = true
require("bufferline").setup{
   options = {
    numbers = "ordinal", -- 显示序号
    close_icon = '✖', -- 关闭图标
    buffer_close_icon = '✖',
  }
}
