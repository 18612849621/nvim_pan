require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "cpp", "python", "java", "cuda", "lua", "proto", "json", "json5",
                       "vim", "vimdoc", "query",
                       "gitignore"},

  indent = {enable = true},
  highlight = {enable = true},
}
