" Enable colors in the terminal
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Escape should exit terminal insert mode
:tnoremap <Esc><Esc> <C-\><C-n>

" And all the regular vim things
if filereadable(glob("~/.vimrc"))
	source ~/.vimrc
endif

