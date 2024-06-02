runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()
execute pathogen#helptags()

"let g:onedark_terminal_italics=1
"colorscheme onedark
colorscheme one
let g:one_allow_italics = 1
set background=dark

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
if has('signcolumn')
  set signcolumn=yes
end

nnoremap <C-P> <cmd>Telescope git_files<cr>
nnoremap gb <cmd>Telescope buffers<cr>
nnoremap <leader>. <cmd>Telescope tags<cr>

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
	" Use Ag over Grep
	set grepprg=ag\ --nogroup\ --nocolor\ --column
	set grepformat=%f:%l:%c%m
endif

" Color gutter marks appropriately in vim-signature
let g:SignatureMarkTextHLDynamic = 1

" Disable gitgutter key bindings
let g:gitgutter_map_keys = 0

" Startify fortune!
if executable('fortune')
	let g:startify_custom_header = map(split(system('fortune'), '\n'), '"   ". v:val') + ['','']
endif
let g:startify_fortune_use_unicode = 0

" Wrestle YouCompleteMe into behaving
" Tweak the identifier popup, and disable some highlighting
set completeopt-=preview

" Make Syntastic use C++11
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++14'
" Don't use Java plugin (use vim-javacomplete).  Java plugin is dumb anyway.
let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "passive_filetypes": ["java"]
\ }
let g:syntastic_python_flake8_args='--ignore=E501'

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

let g:tex_flavor = 'latex'
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

" jedi.vim
let g:jedi#popup_select_first = 0
let g:jedi#goto_assignments_command="gd"

" Incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" vim-highlightedyank
let g:highlightedyank_highlight_duration = 600

" ALE
let g:ale_c_parse_compile_commands = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_linters = {
\   'c': ['clangtidy'],
\   'cpp': ['clangtidy'],
\   'rust': ['rls', 'cargo'],
\   'systemverilog': ['yosys'],
\   'verilog': ['yosys'],
\}
let g:ale_c_build_dir_names = ['build', 'bin', 'build-debug', 'build-release', 'cmake-build-debug', 'cmake-build-release', 'cmake_build']
" You should not turn this setting on if you wish to use ALE as a completion
" source for other completion plugins, like Deoplete.
let g:ale_completion_enabled = 1
imap <C-Space> <Plug>(ale_complete)
" Bind ALE's GoTo to something useful: currently the brain-dead `gd`
" function does nothing useful most of the time
" And I won't miss the default functionality if ALE isn't running
autocmd FileType c nnoremap gd :ALEGoToDefinition<cr>
autocmd FileType cpp nnoremap gd :ALEGoToDefinition<cr>
autocmd FileType rust nnoremap gd :ALEGoToDefinition<cr>
autocmd FileType c nnoremap gD :vsplit<cr>:ALEGoToDefinition<cr>
autocmd FileType cpp nnoremap gD :vsplit<cr>:ALEGoToDefinition<cr>
autocmd FileType rust nnoremap gD :vsplit<cr>:ALEGoToDefinition<cr>

let g:ale_verilog_yosys_options = '-Q -T -p ''read_verilog -sv %s'''
let g:ale_systemverilog_yosys_options = '-Q -T -p ''read_verilog -sv %s'''

" https://github.com/vim-python/python-syntax
let g:python_highlight_all = 1
