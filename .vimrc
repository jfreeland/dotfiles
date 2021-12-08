set nocompatible

execute pathogen#infect()

filetype off
set rtp+=~/.vim/bundle/Vundle.vim
"Check it - https://github.com/abatilo/vimrc/blob/master/.vimrc
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
"Plugin 'Valloric/YouCompleteMe'
Plugin 'altercation/vim-colors-solarized'
Plugin 'martinda/Jenkinsfile-vim-syntax'
Plugin 'rkulla/pydiction'
Plugin 'neoclide/coc.nvim'
Plugin 'vim-airline/vim-airline'
Plugin 'fatih/vim-go'
Plugin 'fatih/vim-hclfmt'
Plugin 'tpope/vim-fugitive'
Plugin 'andrewstuart/vim-kubernetes'
Plugin 'hashivim/vim-terraform'
Plugin 'aperezdc/vim-template'
Plugin 'mustache/vim-mustache-handlebars'
call vundle#end()

set term=screen-256color
set t_ut=
set t_Co=256

filetype plugin indent on

set tw=80
set number
set relativenumber
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set backspace=indent,eol,start
set ruler
set hlsearch
set pastetoggle=<F9>

" Go setup
au FileType go set noexpandtab
au FileType go set shiftwidth=4
au FileType go set softtabstop=4
au FileType go set tabstop=4

" Store temporary files in a central spot
set backup
set backupdir=/tmp
set directory=/tmp

syntax enable
set background=dark
let g:solarized_termcolors=256
let g:pydiction_location = '/home/joey/.vim/bundle/pydiction/complete-dict'
let g:pydiction_menu_height = 3

colorscheme solarized
