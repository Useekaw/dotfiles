# setting and editing env variables

# Vars
export EDITOR='nvim'
export SUDO_EDITOR='nvim'

export CACHE_DIR=~/.cache
export CONFIG_DIR=~/.config

# ZSH Vars
export ZSH_CACHE_DIR=$CACHE_DIR/zsh
export ZSH_CONFIG_DIR=$CONFIG_DIR/zsh

# PATH
export PATH=$PATH:$HOME/.bin:/usr/local/bin:$HOME/.local/bin

typeset -U PATH # remove duplicates
