if &compatible
    set nocompatible
endif

filetype off

call plug#begin('~/.cache/nvim/plugged')
    Plug 'tpope/vim-sensible'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    " Plug 'iCyMind/NeoSolarized'
    Plug 'morhetz/gruvbox'
    Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
    Plug 'ryanoasis/vim-devicons'
    Plug 'airblade/vim-gitgutter'
    Plug 'neoclide/coc.nvim', {'merge':0, 'rev':'release'}
call plug#end()

filetype plugin indent on
