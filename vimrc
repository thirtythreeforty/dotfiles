set nocompatible

set t_Co=256

set backspace=indent,eol,start
set showcmd
set showmode
set autoread
set autochdir

scriptencoding utf-8
set encoding=utf-8

set background=dark
set cursorline
set guicursor+=a:blinkon0
set guifont=Inconsolata-g\ for\ Powerline\ 12
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
" Some older versions of Vim don't have this
if exists('&breakindent')
	set breakindent
endif

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

set list listchars=tab:»\ ,trail:·

set updatetime=500

set scrolloff=2

" Allow modified buffers to be hidden
set hidden

" Open windows to the right and below
set splitbelow
set splitright

" Set leader to ,
let mapleader = ","

" Search but don't jump
nnoremap <leader>* :let b:wv = winsaveview()<CR>*``:call winrestview(b:wv)<CR>
nnoremap <leader># :let b:wv = winsaveview()<CR>#``:call winrestview(b:wv)<CR>

au BufRead,BufNewFile *.md set filetype=markdown
syntax enable

" Allow plugins to interact with filetypes!
filetype plugin on

" Ctrl-J and Ctrl-K insert blank lines, remaining in command mode
nnoremap <silent><C-j> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><C-k> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" insert one character
function! RepeatChar(char, count)
	return repeat(a:char, a:count)
endfunction
nnoremap \ :<C-U>exec "normal i".RepeatChar(nr2char(getchar()), v:count1)<CR>
nnoremap <C-\> :<C-U>exec "normal a".RepeatChar(nr2char(getchar()), v:count1)<CR>

" Keep selection after (un)indent
vnoremap > >gv
vnoremap < <gv

" Disable Ex mode
nnoremap Q <nop>

" Make Y yank to end of line (as suggested by Vim help)
:noremap Y y$

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

" Delete previous word with Ctrl-Backspace
imap <C-BS> <C-W>
imap <C-_> <C-W>

inoremap <S-Tab> <C-D>

nnoremap <Space> :

" Don't use swap files.  Move other files to ~/.vim
set swapfile!
set backupdir+=~/.vim/backup//
if exists('&undofile')
	set undodir=~/.vim/undo//
	set undofile
endif

" Plugin time!

runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
execute pathogen#helptags()

" Colorscheme is PaperColor, but change the background
let g:PaperColor_Dark_Override = {
	\ 'background': '#000000',
\ }
colorscheme PaperColor

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
let g:gitgutter_sign_column_always = 1

" CtrlPTag with <leader>.
nnoremap <leader>. :CtrlPTag<cr>

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
	" Use Ag over Grep
	set grepprg=ag\ --nogroup\ --nocolor

	" Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
	let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

	" ag is fast enough that CtrlP doesn't need to cache
	let g:ctrlp_use_caching = 0
endif

" Color gutter marks appropriately in vim-signature
let g:SignatureMarkTextHLDynamic = 1

" Disable gitgutter key bindings
let g:gitgutter_map_keys = 0

" Startify fortune!
if executable('fortune')
	let g:startify_custom_header = map(split(system('fortune'), '\n'), '"   ". v:val') + ['','']
endif

" Wrestle YouCompleteMe into behaving
" Tweak the identifier popup, and disable some highlighting
let g:ycm_min_num_of_chars_for_completion = 4
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_seed_identifiers_with_syntax = 1
set completeopt-=preview

" Make Syntastic use C++11
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++14'

" Goyo and Limelight for anti-distraction writing
let g:goyo_width=100
augroup Goyo
	autocmd!
	autocmd User GoyoEnter Limelight
	autocmd User GoyoLeave Limelight!
augroup end
nnoremap <F12> :Goyo<CR>

" DetectIndent defaults to 8, but that's ridiculous
let g:detectindent_preferred_indent = 4
let g:detectindent_min_indent = 2
let g:detectindent_max_indent = 8
augroup DetectIndent
	autocmd!
	autocmd BufReadPost *  DetectIndent
augroup end

" Integrate YCM and VimTex, from the VimTex help file
if !exists('g:ycm_semantic_triggers')
	let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers.tex = [
	\ 're!\\[A-Za-z]*(ref|cite)[A-Za-z]*([^]]*])?{([^}]*, ?)*'
	\ ]

" Prefer Okular for PDF viewing with VimTex
if executable('okular')
	let g:vimtex_view_general_viewer = 'okular'
	let g:vimtex_view_general_options = '--unique @pdf\#src:@line@tex'
	let g:vimtex_view_general_options_latexmk = '--unique'
endif

" Integrate Racer and YCM
let g:ycm_semantic_triggers.rust = [ '->', '.', '::' ]

" Close buffer without closing window with :bc
cabbrev bc Sayonara!

" SimpylFold wants these :|
autocmd BufWinEnter *.py setlocal foldexpr=SimpylFold(v:lnum) foldmethod=expr
autocmd BufWinLeave *.py setlocal foldexpr< foldmethod<

" Local hook:
if filereadable(glob("~/.vimrc_local"))
	source ~/.vimrc_local
endif
