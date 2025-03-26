local m = {}
local nvim_lsp = require('lspconfig')
local util = require 'lspconfig/util'

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.diagnostic.config({
    virtual_text = {
        -- source = "always",  -- Or "if_many"
        -- prefix = '●', -- Could be '■', '▎', 'x'
    },
    severity_sort = true,
    float = {
        source = "always", -- Or "if_many"
    },
})

-- Setup nvim-cmp.
local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
local cmp = require 'cmp'
local lspkind = require('lspkind')

local source_mapping = {
    buffer = "[Buffer]",
    nvim_lsp = "[LSP]",
    nvim_lua = "[Lua]",
    luasnip = "[LuaSnip]",
    path = "[Path]",
}

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    completion = {
        autocomplete = false, -- disable auto-completion.
    },
    performance = {
        trigger_debounce_time = 500,
    },
    mapping = {
        ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
        ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
        ['<CR>'] = cmp.mapping.confirm({
            select = false,
            behavior = cmp.ConfirmBehavior.Insert,

        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<C-k>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = lspkind.presets.default[vim_item.kind]
            local menu = source_mapping[entry.source.name]
            vim_item.menu = menu
            return vim_item
        end
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'luasnip' }, -- For luasnip users.
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})


-- Setup lspconfig.

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
m.on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    -- Mappings.
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    -- replaced by telescope
    -- buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

    vim.api.nvim_create_user_command('LR',
        function()
            vim.api.nvim_command('LspRestart')
            vim.diagnostic.reset()
        end,
        { nargs = 0 }
    )

    -- -- disable formatting with tsserver and use eslint
    -- if client.name == "eslint" then
    --     client.server_capabilities.documentFormattingProvider = true
    --     buf_set_keymap("n", "ff", "<cmd>ALEFix<CR>", opts)
    --     return
    -- elseif client.name == "tsserver" then
    --     client.server_capabilities.documentFormattingProvider = false
    -- end
    -- Set some keybinds conditional on server capabilities
    if client.server_capabilities.documentFormattingProvider then
        buf_set_keymap("n", "ff", "<cmd>lua vim.lsp.buf.format{async=true}<CR>", opts)
    end
    if client.name == "templ" then
        buf_set_keymap("n", "ff", "<cmd>lua require(\"conform\").format{async=true}<CR>", opts)
        return
    end
end

nvim_lsp.gopls.setup {
    cmd = { 'gopls', 'serve' },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    on_attach = m.on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            analyses = {
                unusedparams = true,
                unreachable = true,
                shadow = true,
                nilness = true,
                unusedwrite = true,
            },
            hints = {
                compositeLiteralTypes = false,
                compositeLiteralFields = false,
            },
            staticcheck = true,
            templateExtensions = { "gotmpl" },
        },
    },
}

nvim_lsp.lua_ls.setup {
    on_attach = m.on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
    settings = {
        Lua = {
            format = {
                enable = true,
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "2",
                }
            },
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

nvim_lsp.ccls.setup {
    on_attach = m.on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
    init_options = {
        compilationDatabaseDirectory = "build",
        index = {
            threads = 0,
        },
        clang = {
            excludeArgs = { "-frounding-math" },
        },
    }
}

nvim_lsp.volar.setup {
    on_attach = m.on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
    root_dir = util.root_pattern("package.json", ".git/"),
    init_options = {
        typescript = {
            tsdk = '/usr/lib/node_modules/typescript/lib'
        }
    }
}

nvim_lsp.yamlls.setup {
    on_attach = m.on_attach,
    flags = {
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
    settings = {
        yaml = {
            keyOrdering = false,
        }
    }
}

nvim_lsp.golangci_lint_ls.setup {
    on_attach = m.on_attach,
    capabilities = capabilities,
    init_options = {
        command = { "golangci-lint", "run", "--enable", "errcheck,gosimple,govet,ineffassign,staticcheck,unused,exhaustive,ginkgolinter,gocritic,gosec,wrapcheck", "--out-format", "json", "--issues-exit-code=1" },
    }
}

-- nvim_lsp.bashls.setup {}
-- nvim_lsp.cmake.setup {}
-- nvim_lsp.rust_analyzer.setup {}
-- nvim_lsp.eslint.setup {}
-- nvim_lsp.tsserver.setup {}
-- nvim_lsp.svelte.setup {}
-- commented servers are configured above
local servers = {
    -- 'ccls',
    -- 'gopls',
    -- 'golangci_lint_ls',
    -- 'yamlls',
    'volar',
    'lua_ls',
    'pyright',
    'ts_ls',
    'eslint',
    'svelte',
    'html',
    'templ',
    'tailwindcss',
    'cmake',
    'autotools_ls',
    'bashls',
    'rust_analyzer'
}

for _, lsp in ipairs(servers) do
    nvim_lsp[lsp]["setup"] {
        on_attach = m.on_attach,
        flags = {
            debounce_text_changes = 150,
        },
        capabilities = capabilities,
    }
end



function goimports(timeoutms)
    local gopls_encoding = nil
    for _, client in ipairs(vim.lsp.get_active_clients()) do
        if client.name == "gopls" then
            gopls_encoding = client.offset_encoding
            break
        end
    end

    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
            if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, gopls_encoding)
            else
                vim.lsp.buf.execute_command(r.command)
            end
        end
    end
end

-- vim.lsp.set_log_level("debug")
vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
    group = vim.api.nvim_create_augroup("user_diagnostic_qflist", {}),
    callback = function(args)
    -- Use pcall because I was getting inconsistent errors when quitting vim.
    -- Possibly timing errors from trying to get/create diagnostics/qflists
    -- that don't exist anymore. DiagnosticChanged fires at some strange times.
    local has_diagnostics, diagnostics = pcall(vim.diagnostic.get)
    local has_qflist, qflist = pcall(vim.fn.getqflist, { title = 0, id = 0, items = 0 })
    if not has_diagnostics or not has_qflist then return end

    -- Sometimes the event fires with an empty diagnostic list in the data.
    -- This conditional prevents re-creating the qflist with the same
    -- diagnostics, which reverts selection to the first item.
    if
      #args.data.diagnostics == 0
      and #diagnostics > 0
      and qflist.title == "All Diagnostics"
      and #qflist.items == #diagnostics
    then
      return
    end

    vim.schedule(function()
      -- If the last qflist was created by this autocmd, replace it so other
      -- lists (e.g., vimgrep results) aren't buried due to diagnostic changes.
      pcall(vim.fn.setqflist, {}, qflist.title == "All Diagnostics" and "r" or " ", {
        title = "All Diagnostics",
        items = vim.diagnostic.toqflist(diagnostics),
      })

      -- Don't steal focus from other qflists. For example, when working
      -- through vimgrep results, you likely want :cnext to take you to the
      -- next match, rather than the next diagnostic. Use :cnew to switch to
      -- the diagnostic qflist when you want it.
      if qflist.id ~= 0 and qflist.title ~= "All Diagnostics" then pcall(vim.cmd.cold) end
    end)
  end,
})

local snippets_paths = function()
    local plugins = { "friendly-snippets" }
    local paths = {}
    local path
    local root_path = vim.env.HOME .. "/.config/nvim/plugged/"
    for _, plug in ipairs(plugins) do
        path = root_path .. plug
        if vim.fn.isdirectory(path) ~= 0 then
            table.insert(paths, path)
        end
    end
    return paths
end

require("luasnip.loaders.from_vscode").lazy_load({
    paths = snippets_paths(),
    include = nil, -- Load all languages
    exclude = {},
})

return m
