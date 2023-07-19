vim.o.completeopt = 'menu,menuone,noinsert'

vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { bg='NONE', strikethrough=true, fg='#808080' })

vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { bg='NONE', fg='#98971a' })
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link='CmpIntemAbbrMatch' })

vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { bg='NONE', fg='#076678' })
vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { link='CmpItemKindVariable' })
vim.api.nvim_set_hl(0, 'CmpItemKindText', { link='CmpItemKindVariable' })

vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { bg='NONE', fg='#fabd2f' })
vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { link='CmpItemKindFunction' })

vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { bg='NONE', fg='#d65d0e' })
vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link='CmpItemKindKeyword' })
vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { link='CmpItemKindKeyword' })

-- Add vim-dadbod-completion in sql files
_ = vim.cmd [[
  augroup DadbodSql
    au!
    autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer { sources = { { name = 'vim-dadbod-completion' } } }
  augroup END
]]
