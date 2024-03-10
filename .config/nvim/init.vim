syntax on
set encoding=utf-8
set number
set ruler
set autoindent
set mouse=a
set ts=2 sts=2 sw=2
set splitright
set cursorline
set hlsearch
set hidden
set spelllang=en,cjk
set spell

set splitbelow
set splitright
" Give more space for displaying messages.
set cmdheight=2
" Remove limit for syntax highlighting
set synmaxcol=0

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=50
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
set termguicolors
set clipboard+=unnamedplus
set signcolumn=yes
set isfname+=@-@ "accept @ as part of filename
" reselect yanked text while pasting
xnoremap p pgvy
set laststatus=3 "use global statusline
set colorcolumn=120
let mapleader=" "
set undolevels=1000
set undofile
set undodir=~/.nvim/undodir
set relativenumber
set scrolloff=8

" exit terminal mode
tnoremap <esc> <C-\><C-N>

set nocompatible   " be improved, required
filetype off       " required

" store the plugins in plugged dir
call plug#begin('~/.config/nvim/plugged')
Plug 'morhetz/gruvbox'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'mkitt/tabline.vim'
Plug 'mbbill/undotree'

Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'rafamadriz/friendly-snippets'
Plug 'alloyed/lua-lsp'
Plug 'mfussenegger/nvim-jdtls'

Plug 'ThePrimeagen/harpoon', {'branch': 'harpoon2'}

Plug 'mfussenegger/nvim-dap', {'tag': '0.3.0'}
Plug 'rcarriga/nvim-dap-ui'
Plug 'theHamsta/nvim-dap-virtual-text'

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-treesitter/playground'
Plug 'nvim-lua/plenary.nvim'

Plug 'numToStr/Comment.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'kristijanhusak/vim-dadbod-completion'

Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

Plug 'stevearc/conform.nvim'

" Plug 'richardbizik/nvim-toc'
Plug '/mnt/fast/projects/personal/nvim-toc'
call plug#end()

let g:NERDTreeChDirMode = 2
let g:tablineclosebutton=1
" select the color scheme
colorscheme gruvbox
" go hightlights
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1
let g:go_auto_sameids = 1
let g:go_auto_type_info = 1

lua require("treesitter")
source ~/.config/nvim/telescope.vim
source ~/.config/nvim/harpoon.lua
source ~/.config/nvim/harpoon.lua
source ~/.config/nvim/lualine.vim
source ~/.config/nvim/nerdtree.vim
source ~/.config/nvim/dap.vim
source ~/.config/nvim/secret.vim

lua require("Comment").setup()
lua require("lsp_config")
lua require("templ")
lua require("colorizer").setup()
lua require("nvim-toc").setup()

hi LspDiagnosticsVirtualTextError guifg=red gui=bold,italic,underline
hi LspDiagnosticsVirtualTextWarning guifg=orange gui=bold,italic,underline
hi LspDiagnosticsVirtualTextInformation guifg=yellow gui=bold,italic,underline
hi LspDiagnosticsVirtualTextHint guifg=green gui=bold,italic,underline

autocmd BufWritePre *.go lua vim.lsp.buf.format({async=true})
autocmd BufWritePre *.go lua goimports(1000)
autocmd BufWritePre *.templ lua goimports(1000)


vmap <silent> <leader>ts :'<,'>!gojson<CR>
vmap <Tab> >gv
vmap <S-Tab> <gv

imap <C-H> <C-W>

" " move selected lines
" nnoremap K :m .-2<CR>==
" nnoremap J :m .+1<CR>==
" vnoremap K :m '<-2<CR>gv=gv
" vnoremap J :m '>+1<CR>gv=gv

" markdown preview
let g:mkdp_auto_close = 0
" xml folding
augroup XML
    autocmd!
    autocmd FileType xml setlocal foldmethod=indent foldlevelstart=999 foldminlines=0
augroup END

lua << EOF
require("conform").setup({
  formatters_by_ft = {
    templ = { "templ" },
  },
})
local random = math.random
local function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end
vim.api.nvim_create_user_command('UUID',
    function()
        local pos = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_get_current_line()
        local nline = line:sub(0, pos) .. uuid() .. line:sub(pos + 1)
        vim.api.nvim_set_current_line(nline)
    end,
    { nargs = 0 }
)

vim.api.nvim_create_user_command('PathToClipboard',
    function()
		  local currPath = vim.fn.expand('%:p')
			vim.fn.setreg('+', currPath)
    end,
    { nargs = 0 }
)

vim.keymap.set("v", "<SC-J>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<SC-K>", ":m '<-2<CR>gv=gv")
EOF

