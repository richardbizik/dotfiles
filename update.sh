#!/usr/bin/bash


# neovim
cp ~/.config/nvim/cmp.vim ./.config/nvim/
cp ~/.config/nvim/dap.vim ./.config/nvim/
cp ~/.config/nvim/harpoon.vim ./.config/nvim/
cp ~/.config/nvim/init.vim ./.config/nvim/
cp ~/.config/nvim/lua/*.lua ./.config/nvim/lua/
cp ~/.config/nvim/lualine.vim ./.config/nvim/
cp ~/.config/nvim/nerdtree.vim ./.config/nvim/
cp ~/.config/nvim/telescope.vim ./.config/nvim/
cp ~/.config/nvim/treesitter.vim ./.config/nvim/
cp ~/.config/nvim/vsnip.vim ./.config/nvim/
cp ~/.config/nvim/ftplugin/*.lua ./.config/nvim/ftplugin

# snippets
cp ~/.vsnip/*.json ./.vsnip/

# kitty
cp ~/.config/kitty/kitty.conf ./.config/kitty/ 

# tmux
cp ~/.config/tmux/tmux.conf ./.config/tmux/tmux.conf

# i3 & polybar
cp -R ~/.config/i3/. ./.config/i3
cp -R ~/.config/polybar/. ./.config/polybar
