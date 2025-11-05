" ------------------------------
" RUN VIM WITHOUT COLOUR
" ------------------------------
set t_Co=0

" ------------------------------
"  Bootstrap vim-plug if not already installed
" ------------------------------
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ------------------------------
" Basic settings
" ------------------------------
set nocompatible
syntax on
set nowrap
filetype plugin indent on
set number relativenumber
set tabstop=4 shiftwidth=4 expandtab
set encoding=utf-8

" ------------------------------
" Plugin block
" ------------------------------
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
call plug#end()
