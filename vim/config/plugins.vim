runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
execute pathogen#helptags()

let g:onedark_terminal_italics=1
colorscheme onedark

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
set signcolumn=yes

" CtrlPTag with <leader>.
nnoremap <leader>. :CtrlPTag<cr>

" CtrlPBuffer with gb
nnoremap gb :CtrlPBuffer<cr>

" CtrlP should not recurse ad nauseum
let g:ctrlp_max_depth = 8

" CtrlP should ignore what VCS ignores (pasted from its manual)
let g:ctrlp_user_command = {
\ 'types': {
  \ 1: ['.git', "cd '%s' && git ls-files --exclude-standard -co"],
  \ 2: ['.hg', 'hg --cwd %s locate -I .'],
  \ },
\ }

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
	" Use Ag over Grep
	set grepprg=ag\ --nogroup\ --nocolor\ --column
	set grepformat=%f:%l:%c%m

	" Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
	let g:ctrlp_user_command['fallback'] = 'ag %s -l --nocolor -g ""'

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
autocmd FileType rust nnoremap gd :YcmCompleter GoTo<cr>
autocmd FileType c nnoremap gD :vsplit<cr>:YcmCompleter GoTo<cr>
autocmd FileType cpp nnoremap gD :vsplit<cr>:YcmCompleter GoTo<cr>
autocmd FileType rust nnoremap gD :vsplit<cr>:YcmCompleter GoTo<cr>

" Make Syntastic use C++11
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++14'
" Don't use Java plugin (use vim-javacomplete).  Java plugin is dumb anyway.
let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ["java"]
\ }

" Goyo and Limelight for anti-distraction writing
let g:goyo_width=100
augroup Goyo
	autocmd!
	autocmd User GoyoEnter Limelight
	autocmd User GoyoLeave Limelight!
augroup end
nnoremap <silent> <F12> :Goyo<CR>

" DetectIndent defaults to 8, but that's ridiculous
let g:detectindent_preferred_indent = 4
let g:detectindent_min_indent = 2
let g:detectindent_max_indent = 4
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

" The ` mappings are more irritating than helpful.  In particular, they break
" lexima.vim mappings.
let g:vimtex_imaps_enabled = 0

" Configure YCM's Racer
"let g:ycm_rust_src_path = '/path/to/rust/src'

" Close buffer without closing window with :bc
cabbrev bc Sayonara!
nnoremap <silent> <leader>q :Sayonara!<CR>

" Git status with gs
nnoremap gs :Gstatus<CR>

" Strip whitespace with <leader><space>
nnoremap <leader><space> :StripWhitespace<CR>

function s:lexima_add_rules(rules, ...)
	for rule in a:rules
		let patchedrule = copy(rule)
		if a:0 > 0
			call extend(patchedrule, {'filetype': a:1})
		endif
		call lexima#add_rule(patchedrule)
	endfor
endfunction

" Extra shortcuts for lexima.vim
call s:lexima_add_rules([
	\ {'char': ')', 'at': '(.*\%#.*)', 'leave': ')'},
	\ {'char': '}', 'at': '{.*\%#.*}', 'leave': '}'},
	\ {'char': ']', 'at': '\[.*\%#.*\]', 'leave': ']'},
	\ {'char': '<Space>', 'at': '( \+.*\%# \+)', 'leave': ' '},
	\ {'char': '<Space>', 'at': '{ \+.*\%# \+}', 'leave': ' '},
	\ {'char': '<Space>', 'at': '\[ \+.*\%# \+\]', 'leave': ' '},
\ ])

" Disable matching quote insertion when at the beginning of a word
call s:lexima_add_rules([
	\ {'char': "'", 'at': '\%#\w'},
	\ {'char': '"', 'at': '\%#\w'},
	\ {'char': '`', 'at': '\%#\w'},
\ ])

" Matching backspace motions for newline rules
call s:lexima_add_rules([
	\ {'char': '<BS>', 'at': '(\n\%#\n\s*)', 'input': '<BS>', 'delete': 1},
	\ {'char': '<BS>', 'at': '\[\n\%#\n\s*]', 'input': '<BS>', 'delete': 1},
	\ {'char': '<BS>', 'at': '{\n\%#\n\s*}', 'input': '<BS>', 'delete': 1},
\ ])

" TeX rules for $ math regions $
" For some reason typing a $ at '$$ | $$' causes leaving the outer $, but this
" is fine for me.
call s:lexima_add_rules([
	\ {'char': '$', 'at': '[^\\]\%#', 'input_after': '$'},
	\ {'char': '<Space>', 'at': '\$\%#\$', 'input_after': '<Space>'},
	\ {'char': '$', 'at': '\$\%#\$', 'input_after': '$'},
	\ {'char': '$', 'at': '\%#\$', 'leave': '$'},
	\ {'char': '$', 'at': '\%# \$', 'leave': '$'},
	\ {'char': '<BS>', 'at': '\$\%#\$', 'delete': 1},
	\ {'char': '<BS>', 'at': '\$ \%# \$', 'delete': 1},
\ ], 'tex')

" TeX rules for ``smart quotes''
call s:lexima_add_rules([
	\ {'char': '`', 'input_after': "'"},
	\ {'char': '<BS>', 'at': "`\%#'", 'delete': 1},
	\ {'char': '<BS>', 'at': "` \%# '", 'delete': 1},
	\ {'char': "'", 'at': "\w\%#'"},
	\ {'char': '`', 'at': '\%#\w'},
\ ], 'tex')

" Streamline generics in Rust and C++
call s:lexima_add_rules([
	\ {'char': '<', 'at': '\w\%#', 'input_after': '>'},
	\ {'char': '>', 'at': '\%#>', 'leave': 1},
	\ {'char': '<BS>', 'at': '\w<\%#>', 'delete': 1},
\ ], ['rust', 'cpp'])

" Extra rules for Rust, especially disabling single-quote matching in <>
" and in where clauses
call s:lexima_add_rules([
	\ {'char': '<', 'at': '::\%#', 'input_after': '>'},
	\ {'char': '>', 'at': '\%#>', 'leave': 1},
	\ {'char': '<BS>', 'at': '::<\%#>', 'delete': 1},
	\ {'char': "'", 'at': '\(\w\|::\)<.*\%#.*>'},
	\ {'char': "'", 'at': '&\%#'},
	\ {'char': "'", 'at': 'where.*:.*\%#'},
\ ], 'rust')

" Insert <> in C and C++ for #include statements
call s:lexima_add_rules([
	\ {'char': '<', 'at': '#include\s\+\%#', 'input_after': '>'},
	\ {'char': '>', 'at': '\%#>', 'leave': 1},
	\ {'char': '<BS>', 'at': '#include\s\+<\%#>', 'delete': 1},
\ ], ['c', 'cpp'])

" Suppress single-quote insertion for text files, except in double-quotes
" as in nested quotations.
call lexima#add_rule({'char': "'", 'except': '".*\%#.*"', 'filetype': 'text'})

" Disable python-mode's completion in favor of YCM's
let g:pymode_rope_completion = 0
" Don't show the nag window full of errors (that's what the sidebar is for)
let g:pymode_lint_cwindow = 0

" Configure EasyMotion as per recommendation of the developer
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Bi-directional find motion
" `s{char}{char}{label}`
nmap s <Plug>(easymotion-overwin-f2)
vmap s <Plug>(easymotion-s2)
omap S <Plug>(easymotion-s2)
" Replace original s (change character) with S
nnoremap S s

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
let g:rainbow#pairs = [['(', ')'], ['[', ']'], ['\\{', '\\}']]

" Swap i and I in targets.vim
let g:targets_aiAI = 'aIAi'
" Angle and curly brackets are containers too
" (think Rust/Java generics, C++ templates, and C++ constructors)
let g:targets_argOpening = '[{(<[]'
let g:targets_argClosing = '[])>}]'
" Semicolons can separate arguments in for(;;) loops
let g:targets_argSeparator = '[,;]'

" vim-asterisk bindings
map *   <Plug>(asterisk-*)
map #   <Plug>(asterisk-#)
map g*  <Plug>(asterisk-g*)
map g#  <Plug>(asterisk-g#)
map z*  <Plug>(asterisk-z*)
map gz* <Plug>(asterisk-gz*)
map z#  <Plug>(asterisk-z#)
map gz# <Plug>(asterisk-gz#)
" Not sure if I like this yet.
"let g:asterisk#keeppos = 1

" vim-search-pulse integration with vim-asterisk
let g:vim_search_pulse_disable_auto_mappings = 1

nmap * <Plug>(asterisk-*)<Plug>Pulse
nmap # <Plug>(asterisk-#)<Plug>Pulse
nmap n n<Plug>Pulse
nmap N N<Plug>Pulse

" Pulses cursor line on first match
" when doing search with / or ?
cmap <silent> <expr> <enter> search_pulse#PulseFirst()

" JavaComplete
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" Incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
