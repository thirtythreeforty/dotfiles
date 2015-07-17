set nocompatible

set t_Co=256

set backspace=indent,eol,start
set showcmd
set showmode
set autoread

set background=dark
highlight Comment ctermfg=darkgray
highlight SpecialKey ctermfg=darkgrey

:set ttimeoutlen=20

set number

set incsearch
set hlsearch
set ignorecase
set smartcase

set wrap
set linebreak

set mouse=a
set mousefocus

" The following settings are to configure the Sleuth plugin.
set tabstop=4
set shiftwidth=4
set softtabstop=4
" These aren't needed because of Sleuth.  Usually.
" set smartindent
" set breakindent
" set expandtab

set list listchars=tab:»\ ,trail:·

set updatetime=500

set scrolloff=2

" Allow modified buffers to be hidden
set hidden

" Open windows to the right and below
set splitbelow
set splitright

" Close buffer without closing window with :bc
command! BufferCloseKeepWindow bp|bd #
cabbrev bc BufferCloseKeepWindow

" Set leader to ,
let mapleader = ","

" Search but don't jump
nnoremap <leader>* *``
nnoremap <leader># #``

" Better highlighting
highlight Search cterm=NONE ctermfg=white ctermbg=blue

au BufRead,BufNewFile *.md set filetype=markdown
syntax enable

" Ctrl-J and Ctrl-K insert blank lines, remaining in command mode
nnoremap <silent><C-j> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><C-k> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" insert one character
noremap \ i<Space><Esc>r
noremap <C-\> a<Space><Esc>r

" Keep selection after (un)indent
vnoremap > >gv
vnoremap < <gv

" Disable Ex mode
nnoremap Q <nop>

" Force quit with qq (easier to type)
cabbrev qq q!
cabbrev qqq qall!

" Reload in DOS line ending mode
cabbrev edos :e ++ff=dos
cabbrev eunix :e ++ff=unix

" Unhighlight with <Leader>/
nnoremap <silent> <Leader>/ :noh<CR>

" Toggle expandtab with <Leader>-Tab
noremap <Leader><Tab> :set expandtab!<CR>

" Delete previous word
imap <C-BS> <C-W>

nnoremap <Space> :

" Don't litter the working directory with .swp files
set backupdir=~/.vim/backup//
set directory=~/.vim/swap//
set undodir=~/.vim/undo//

" Plugin time!

runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
execute pathogen#helptags()

" Display Airline
set laststatus=2
" But the bufferline integration is annoying
let g:airline#extensions#bufferline#enabled = 0
" And so is whitespace detection
let g:airline#extensions#whitespace#enabled = 0
" Enable paste detection
let g:airline_detect_paste=1
" Enable syntastic integration
let g:airline#extensions#syntastic#enabled = 1
" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'
" Allow jumping to a buffer with <leader><number>
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9

" powerline symbols
let g:airline_powerline_fonts=1

" Configure gutter a bit
highlight clear SignColumn
highlight LineNr ctermfg=DarkGrey

" CtrlPTag with <leader>.
nnoremap <leader>. :CtrlPTag<cr>

" Color gutter marks appropriately in vim-signature
let g:SignatureMarkTextHLDynamic = 1

" Startify fortune!
let g:startify_custom_header = map(split(system('fortune'), '\n'), '"   ". v:val') + ['','']

" Wrestle YouCompleteMe into behaving
let g:ycm_auto_trigger = 0
let g:ycm_enable_diagnostic_highlighting = 0

" Make Syntastic use C++11
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++14'

