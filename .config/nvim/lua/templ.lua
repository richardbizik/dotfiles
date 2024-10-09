
vim.filetype.add({ extension = { templ = "templ" } })
vim.api.nvim_create_autocmd({ "BufWritePre" }, { pattern = { "*.templ" }, callback = function(args)
    require("conform").format({ bufnr = args.buf })
end
})
