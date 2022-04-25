syntax on
set encoding=utf-8
set number relativenumber
set ruler
set spelllang=en_us
set autoindent
set mouse=a
set ts=2 sts=2 sw=2
set splitright
set cursorline
set hlsearch
set hidden

set splitbelow
set splitright
" Give more space for displaying messages.
set cmdheight=2
" Remove limit for syntax highlighting
set synmaxcol=0

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
set termguicolors
set clipboard+=unnamedplus
set signcolumn=yes
set isfname+=@-@ "accept @ as part of filename
" reselect yanked text while pasting
set laststatus=3 "use global statusline
xnoremap p pgvy
set colorcolumn=120

" exit terminal mode
tnoremap <esc> <C-\><C-N>

set nocompatible   " be improved, required
filetype off       " required

" store the plugins in plugged dir
call plug#begin('~/.config/nvim/plugged')
Plug 'morhetz/gruvbox'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
Plug 'mkitt/tabline.vim'

Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
Plug 'hrsh7th/vim-vsnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'alloyed/lua-lsp'

Plug 'ThePrimeagen/harpoon'

Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-lua/plenary.nvim'

"Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'numToStr/Comment.nvim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
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

source ~/.config/nvim/telescope.vim
source ~/.config/nvim/harpoon.vim
source ~/.config/nvim/lualine.vim
source ~/.config/nvim/nerdtree.vim
"source ~/.config/nvim/coc.vim
source ~/.config/nvim/cmp.vim
source ~/.config/nvim/vsnip.vim
source ~/.config/nvim/dap.vim
source ~/.config/nvim/secret.vim

lua require('Comment').setup()
lua require("lsp_config")

hi LspDiagnosticsVirtualTextError guifg=red gui=bold,italic,underline
hi LspDiagnosticsVirtualTextWarning guifg=orange gui=bold,italic,underline
hi LspDiagnosticsVirtualTextInformation guifg=yellow gui=bold,italic,underline
hi LspDiagnosticsVirtualTextHint guifg=green gui=bold,italic,underline

autocmd BufWritePre *.go lua vim.lsp.buf.formatting()
autocmd BufWritePre *.go lua goimports(1000)


vmap <Tab> >gv
vmap <S-Tab> <gv

imap <C-H> <C-W>

" markdown preview
let g:mkdp_auto_close = 0
