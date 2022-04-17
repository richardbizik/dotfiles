set completeopt=menu,menuone,noselect

lua <<EOF
  -- Setup nvim-cmp.
  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end

	local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
	end 

	local cmp = require'cmp'
  local lspkind = require('lspkind')
	
	local tabnine = require('cmp_tabnine.config')
	tabnine:setup({
		max_lines = 10000;
		max_num_results = 10;
		sort = true;
		run_on_every_keystroke = true;
		snippet_placeholder = '..';
		ignored_file_types = { 
			-- default is not to ignore
			-- uncomment to ignore in lua:
			-- lua = true
		};
	})
	local source_mapping = {
		buffer = "[Buffer]",
		nvim_lsp = "[LSP]",
		nvim_lua = "[Lua]",
		vsnip = "[Vsnip]",
		cmp_tabnine = "[TN]",
		path = "[Path]",
	}

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
     end,
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
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			["<C-j>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif vim.fn["vsnip#available"](1) == 1 then
							feedkey("<Plug>(vsnip-expand-or-jump)", "")
						-- elseif has_words_before() then
						-- 	cmp.complete()
						else
							fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
						end
					end, { "i", "s" }),
			["<C-k>"] = cmp.mapping(function()
				if cmp.visible() then
					cmp.select_prev_item()
				elseif vim.fn["vsnip#jumpable"](-1) == 1 then
					feedkey("<Plug>(vsnip-jump-prev)", "")
				end
					end, { "i", "s" }),
		},
		formatting = {
        format = function(entry, vim_item)
            vim_item.kind = lspkind.presets.default[vim_item.kind]
            local menu = source_mapping[entry.source.name]
            if entry.source.name == 'cmp_tabnine' then
                if entry.completion_item.data ~= nil and entry.completion_item.data.detail ~= nil then
                    menu = entry.completion_item.data.detail .. ' ' .. menu
                end
                vim_item.kind = ''
            end
            vim_item.menu = menu
            return vim_item
        end
    },
    sources = cmp.config.sources({
		  { name = 'cmp_tabnine' },
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'buffer' },
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
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
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())


  local servers = { 'gopls', 'yamlls', 'pyright' }
	for _, lsp in ipairs(servers) do
		require('lspconfig')[lsp].setup {
			capabilities = capabilities
		}
	end
	local cmp = require('cmp')
	cmp.setup {
		completion = {
			autocomplete = true, -- disable auto-completion.
		},
	}

	_G.vimrc = _G.vimrc or {}
	_G.vimrc.cmp = _G.vimrc.cmp or {}
	_G.vimrc.cmp.lsp = function()
		cmp.complete({
			config = {
				sources = {
					{ name = 'nvim_lsp' }
				}
			}
		})
	end
	_G.vimrc.cmp.snippet = function()
		cmp.complete({
			config = {
				sources = {
					{ name = 'vsnip' }
				}
			}
		})
	end
	vim.cmd([[
		inoremap <C-x><C-o> <Cmd>lua vimrc.cmp.lsp()<CR>
		inoremap <C-x><C-s> <Cmd>lua vimrc.cmp.snippet()<CR>
	]])
EOF
