#!/usr/bin/bash

# profiles
cp ~/.profile ./.profile
cp ~/.bashrc ./.bashrc
cp ~/.zshrc ./.zshrc

# neovim
cp ~/.config/nvim/dap.vim ./.config/nvim/
cp ~/.config/nvim/harpoon.lua ./.config/nvim/
cp ~/.config/nvim/init.vim ./.config/nvim/
cp -R ~/.config/nvim/lua/. ./.config/nvim/lua
cp ~/.config/nvim/lualine.vim ./.config/nvim/
cp ~/.config/nvim/nerdtree.vim ./.config/nvim/
cp ~/.config/nvim/telescope.vim ./.config/nvim/
cp ~/.config/nvim/vsnip.vim ./.config/nvim/
cp -R ~/.config/nvim/after/. ./.config/nvim/after

# kitty
if [ -e "$HOME/.config/kitty/kitty.conf" ]; then
  cp ~/.config/kitty/kitty.conf ./.config/kitty/ 
fi

# tmux
cp ~/.config/tmux/tmux.conf ./.config/tmux/tmux.conf

# i3 & polybar
if [ -e "$HOME/.config/i3" ]; then
	cp -R ~/.config/i3/. ./.config/i3
fi
if [ -e "$HOME/.config/polybar" ]; then
	cp -R ~/.config/polybar/. ./.config/polybar
fi

# sway & waybar & rofi
cp -R ~/.config/sway ./.config/sway
cp -R ~/.config/waybar ./.config/waybar
cp -R ~/.config/rofi ./.config/rofi
cp -R ~/.config/mako ./.config/mako
