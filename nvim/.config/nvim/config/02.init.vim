let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors
set shell=/bin/zsh

" enable syntax highlighting
syntax on
colorscheme gruvbox

" fixes backspace
set backspace=indent,eol,start

" enable line numbers
set number
set relativenumber

" enable line/column info at bottom
set ruler

set scrolloff=10
set updatetime=300

" some language servers have problems with backup files
set nobackup
set nowritebackup

" autoindentation
set autoindent
filetype indent plugin on

" tab stop settings
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

" misc
set hidden
set noshowmode
