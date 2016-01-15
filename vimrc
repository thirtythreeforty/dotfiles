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
set guifont=Inconsolata-g\ for\ Powerline\ 11
" Disable GUI's menu, scrollbar, and toolbar
set guioptions-=m
set guioptions-=T
set guioptions-=r
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
" Some older versions of Vim don't have this
if exists('&breakindent')
	set breakindent
endif
autocmd FileType c setlocal foldmethod=syntax
autocmd FileType cpp setlocal foldmethod=syntax
autocmd FileType c setlocal cindent
autocmd FileType cpp setlocal cindent
set cinoptions=:0,l1,g0,(0
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
au BufRead,BufNewFile *.tex set filetype=tex
au BufRead,BufNewFile SConstruct set filetype=python
au BufRead,BufNewFile SConscript set filetype=python
au BufRead,BufNewFile TAG_EDITMSG set filetype=gitcommit
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
nnoremap <silent>\ :<C-U>exec "normal i".RepeatChar(nr2char(getchar()), v:count1)<CR>
nnoremap <silent><C-\> :<C-U>exec "normal a".RepeatChar(nr2char(getchar()), v:count1)<CR>

" Keep selection after (un)indent
vnoremap > >gv
vnoremap < <gv

" Disable Ex mode, replace it with Execute Lines in Vimscript
function! ExecRange(line1, line2)
	exec join(getline(a:line1, a:line2), "\n")
	echom string(a:line2 - a:line1 + 1) . "L executed"
endfunction
command! -range ExecRange call ExecRange(<line1>, <line2>)

nnoremap Q :ExecRange<CR>
vnoremap Q :ExecRange<CR>

" Make Y yank to end of line (as suggested by Vim help)
:noremap Y y$

" Force quit with qq (easier to type)
cnoreabbrev qq q!
cnoreabbrev qqq qall!

" Reload in DOS line ending mode
cnoreabbrev edos :e ++ff=dos
cnoreabbrev eunix :e ++ff=unix

" Unhighlight with <Leader>/
nnoremap <silent> <Leader>/ :noh<CR>

" Toggle recent buffer with <Leader>-Tab
nnoremap <Leader><Tab> :b#<CR>

" Delete previous word with Ctrl-Backspace
imap <C-BS> <C-W>
imap <C-_> <C-W>

inoremap <S-Tab> <C-D>

" Hitting Space is much easier than hitting Shift-;
nnoremap <Space> :

" Easy mapping for Sayonara!
nnoremap <leader>q :Sayonara!<CR>

" Disable auto-commenting new lines, everywhere.  Must use a FileType hook
" because BufRead hooks execute before all the irritating builtin ones that
" add these options.
autocmd FileType * setlocal formatoptions-=ro

" Don't use swap files.  Move other files to ~/.vim
set swapfile!
set backupdir+=~/.vim/backup//
if exists('&undofile')
	set undodir=~/.vim/undo//
	set undofile
endif

" Use tree mode in netrw
let g:netrw_liststyle=3

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

" CtrlP should not recurse ad nauseum
let g:ctrlp_max_depth = 15

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
	" Use Ag over Grep
	set grepprg=ag\ --nogroup\ --nocolor\ --column
	set grepformat=%f:%l:%c%m

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
let g:ycm_complete_in_comments = 1
let g:ycm_confirm_extra_conf = 0
if !exists('g:ycm_semantic_triggers')
	let g:ycm_semantic_triggers = {}
endif
set completeopt-=preview
" Bind YCM's GoTo to something useful: currently the brain-dead `gd`
" function does nothing useful most of the time
" And I won't miss the default functionality if YCM isn't running
autocmd FileType c nnoremap gd :YcmCompleter GoTo<cr>
autocmd FileType cpp nnoremap gd :YcmCompleter GoTo<cr>
autocmd FileType c nnoremap gD :vsplit<cr>:YcmCompleter GoTo<cr>
autocmd FileType cpp nnoremap gD :vsplit<cr>:YcmCompleter GoTo<cr>

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
let g:ycm_semantic_triggers.tex = [
	\ 're!\\[A-Za-z]*(ref|cite)[A-Za-z]*([^]]*])?{([^}]*, ?)*'
	\ ]

" Use XeLaTeX
let g:vimtex_latexmk_options = "-pdf -lualatex"

" Prefer Okular for PDF viewing with VimTex
if executable('okular')
	let g:vimtex_view_general_viewer = 'okular'
	let g:vimtex_view_general_options = '--unique @pdf\#src:@line@tex'
	let g:vimtex_view_general_options_latexmk = '--unique'
endif

" Configure Racer
let g:racer_cmd = "~/dotfiles/racer/target/release/racer"
"let $RUST_SRC_PATH="<path-to-rust-srcdir>/src/"

" Integrate Racer and YCM
let g:ycm_semantic_triggers.rust = [ '->', '.', '::' ]

" Close buffer without closing window with :bc
cabbrev bc Sayonara!

" Git status with gs
nnoremap gs :Gstatus<CR>

" Strip whitespace with <leader><space>
nnoremap <leader><space> :StripWhitespace<CR>

" Extra shortcuts for lexima.vim
call lexima#add_rule({'char': ')', 'at': '(.*\%#.*)', 'leave': ')'})
call lexima#add_rule({'char': '}', 'at': '{.*\%#.*}', 'leave': '}'})
call lexima#add_rule({'char': ']', 'at': '\[.*\%#.*\]', 'leave': ']'})
call lexima#add_rule({'char': '<Space>', 'at': '( \+.*\%# \+)', 'leave': ' '})
call lexima#add_rule({'char': '<Space>', 'at': '{ \+.*\%# \+}', 'leave': ' '})
call lexima#add_rule({'char': '<Space>', 'at': '\[ \+.*\%# \+\]', 'leave': ' '})

" Disable python-mode's completion in favor of YCM's
let g:pymode_rope_completion = 0
" Don't show the nag window full of errors (that's what the sidebar is for)
let g:pymode_lint_cwindow = 0

" vim-javascript allows concealing certain characters
let g:javascript_conceal_function   = "ƒ"
"let g:javascript_conceal_null       = "ø"
"let g:javascript_conceal_this       = "@"
"let g:javascript_conceal_return     = "⇚"
"let g:javascript_conceal_undefined  = "¿"
"let g:javascript_conceal_NaN        = "ℕ"
"let g:javascript_conceal_prototype  = "¶"
"let g:javascript_conceal_static     = "•"
"let g:javascript_conceal_super      = "Ω"

" Configure EasyMotion as per recommendation of the developer
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Bi-directional find motion
" `s{char}{char}{label}`
nmap s <Plug>(easymotion-s2)

" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_us = 1
" Use uppercase target labels and type as a lower case
let g:EasyMotion_use_upper = 1
let g:EasyMotion_keys = 'FJDKSLA;GHRUEITYWOQPVNCMBXZ'

" Recolor EasyMotion targets (I can't see reds very well)
hi link EasyMotionTargetDefault ErrorMsg

" FastFold settings:
" Update folds when opening/closing them
let g:fastfold_fold_command_suffixes = ['x','X','a','A','o','O','c','C','r','R','m','M','i','n','N']

" rainbow_parentheses.vim should rainbow-ify {} and [] too
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['{', '}']]

" Local hook:
if filereadable(glob("~/.vimrc_local"))
	source ~/.vimrc_local
endif
