" Enable colors in the terminal
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Enable cursor shapes in terminal
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1

" Escape should exit terminal insert mode
:tnoremap <Esc><Esc> <C-\><C-n>

" Vterm opens a new vertically-split terminal
command! Vterm vsplit | terminal
command! Sterm split | terminal

" And all the regular vim things
if filereadable(glob("~/.vimrc"))
	source ~/.vimrc
endif

