set nocompatible

set t_Co=256

set backspace=indent,eol,start
set showcmd
set showmode
set autoread
set autochdir

syntax enable

scriptencoding utf-8
set encoding=utf-8

set background=dark
set cursorline
set guicursor+=a:blinkon0
set guifont=Inconsolata-g\ for\ Powerline\ 11
" Disable GUI's menu, scrollbar, and toolbar
set guioptions-=m
set guioptions-=T
set guioptions-=l
set guioptions-=r
set fillchars+=vert:┃,fold:┄
highlight Comment ctermfg=244
highlight SpecialKey ctermfg=darkgrey
highlight CursorLine cterm=NONE ctermbg=235
highlight Search cterm=NONE ctermfg=white ctermbg=blue

set ttimeoutlen=20

set number

set incsearch
set hlsearch
set ignorecase
set smartcase
set wildignorecase

set wrap
set linebreak
set autoindent
set smartindent
set copyindent
if exists('&breakindent')
	set breakindent
endif
autocmd FileType c setlocal foldmethod=syntax
autocmd FileType cpp setlocal foldmethod=syntax
autocmd FileType c setlocal cindent
autocmd FileType cpp setlocal cindent
set cinoptions=:0,l1,g0,(0,Ws,N-s,m1
set cinkeys=0{,0},0),:,0#,!<Tab>,o,O,e

set mouse=a
set mousefocus
" Make mouse work in Cygwin, but only in Vim, not Neovim
if !has('nvim')
	set ttymouse=xterm2
endif

" Help DetectIndent with some defaults
set tabstop=4
set shiftwidth=4
set softtabstop=4
" set expandtab

set list listchars=tab:»\ 

set updatetime=500

set scrolloff=2
set sidescroll=1
set sidescrolloff=3

" Allow modified buffers to be hidden
set hidden

" Open windows to the right and below
set splitbelow
set splitright

" Set leader to ,
let mapleader = ","

" Allow plugins to interact with filetypes!
filetype plugin on

" Don't use swap files.  Move other files to ~/.vim
set swapfile!
set backupdir+=~/.vim/backup//
if exists('&undofile')
	set undodir=~/.vim/undo//
	set undofile
endif

" Commands to swap j with gj as needed
function! VisualLinewise(en)
	if a:en == 1
		nnoremap <buffer> j gj
		nnoremap <buffer> k gk
	else
		nunmap <buffer> j
		nunmap <buffer> k
	endif
endfunction
command! EnableVisualLine call VisualLinewise(1)
command! DisableVisualLine call VisualLinewise(0)

" Use tree mode in netrw
let g:netrw_liststyle=3
