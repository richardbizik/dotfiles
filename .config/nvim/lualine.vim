lua << END
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_lsp'}}},
    lualine_c = {
      function()
        local fn = vim.fn.expand('%:~:.')
        if vim.startswith(fn, "jdt://") then
          fn = string.sub(fn, 0, string.find(fn, "?") - 1)
        end
        if fn == '' then
          fn = '[No Name]'
        end
        if vim.bo.modified then
          fn = fn .. ' [+]'
        end
        if vim.bo.modifiable == false or vim.bo.readonly == true then
          fn = fn .. ' [-]'
        end
        local tfn = vim.fn.expand('%')
        if tfn ~= '' and vim.bo.buftype == '' and vim.fn.filereadable(tfn) == 0 then
          fn = fn .. ' [New]'
        end
        return fn
      end
    },
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}
END
