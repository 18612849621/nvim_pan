-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir
local lualine = require('lualine')

-- Color table for highlights
-- stylua: ignore
local colors = {
  bg       = '#202328',
  fg       = '#bbc2cf',
  yellow   = '#ECBE7B',
  cyan     = '#008080',
  darkblue = '#081633',
  green    = '#98be65',
  orange   = '#FF8800',
  violet   = '#a9a1e1',
  magenta  = '#c678dd',
  blue     = '#51afef',
  red      = '#ec5f67',
  pink     = 'FFB3FF' ,
  l_yellow = '#FFFFBB',
}

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 80
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand('%:p:h')
    local gitdir = vim.fn.finddir('.git', filepath .. ';')
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}

-- Config
local config = {
  options = {
    -- Disable sections and component separators
    component_separators = {},
    section_separators = '',
    theme = {
      -- We are going to use lualine_c an lualine_x as left and
      -- right section. Both are highlighted by c theme .  So we
      -- are just setting default looks o statusline
      normal = { c = { fg = colors.fg, bg = colors.blue } },
      inactive = { c = { fg = colors.fg, bg = colors.bg } }, 
    },
  },
  sections = {
    -- these are to remove the defaults
    lualine_a = {}, 
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    -- These will be filled later
    lualine_c = {},
    lualine_x = {},
  },
  inactive_sections = {
    -- these are to remove the defaults
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
  table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
  table.insert(config.sections.lualine_x, component)
end

ins_left {
  -- mode component
  'mode', 
  fmt = function(str)
    if (vim.fn.mode() == 'n') then
        return '   ' .. str
    elseif (vim.fn.mode() == 'v') then
        return ' 󱗆  ' .. str
    else
        return '   ' .. str 
    end
  end,
  color = function()
    -- auto change color according to neovims mode
    local mode_color = {
      n = colors.red,
      i = colors.green,
      v = colors.blue,
      [''] = colors.blue,
      V = colors.blue,
      c = colors.magenta,
      no = colors.red,
      s = colors.orange,
      S = colors.orange,
      [''] = colors.orange,
      ic = colors.yellow,
      R = colors.violet,
      Rv = colors.violet,
      cv = colors.red,
      ce = colors.red,
      r = colors.cyan,
      rm = colors.cyan,
      ['r?'] = colors.cyan,
      ['!'] = colors.red,
      t = colors.red,
    }
    return { fg = colors.bg, bg = mode_color[vim.fn.mode()] }
  end, 
  padding = { right = 1 },
}

ins_left {
  'filename',
  icon = '󰈔',
  cond = conditions.buffer_not_empty,
  color = { fg = colors.bg, bg = colors.pink, gui = 'bold' },
}

ins_left {
  'branch',
  icon = '',
  color = { fg = colors.bg, bg = colors.violet, gui = 'bold' },
}

ins_left { 
  'location', 
  icon = ' ',
  color = { fg = colors.bg, bg = colors.l_yellow, gui = 'bold' },
}

ins_right {
  'datetime',
  fmt = function(str)
    return '󰔠 ' .. str
  end,
  style = ("%Y/%m/%d"), 
  padding = {left = 1, right = 1 }, 
  color = { fg = colors.bg, bg = colors.blue, gui = 'bold' },
}

ins_right {
  'datetime',
  fmt = function(str)
    return '󱑁 ' .. str
  end,
  style = ("%H:%M"),
  padding = { right = 1 }, 
  color = { fg = colors.bg, bg = colors.blue, gui = 'bold' },
}

ins_right {
  'fileformat',
  fmt = string.upper,
  icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
  color = { fg = colors.bg, bg = colors.cyan, gui = 'bold' },
}

ins_right {
  'diff',
  -- Is it me or the symbol for modified us really weird
  symbols = { added = ' ', modified = '  ', removed = '  ' },
  diff_color = {
    added = { fg = colors.bg, bg = colors.green },
    modified = { fg = colors.bg, bg = colors.orange },
    removed = { fg = colors.bg, bg = colors.red },
  },
  cond = conditions.hide_in_width,
}

-- Now don't forget to initialize lualine
lualine.setup(config)
