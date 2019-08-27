" Escape should exit terminal insert mode
:tnoremap <Esc><Esc> <C-\><C-n>

" Vterm opens a new vertically-split terminal
command! Vterm vsplit | terminal
command! Sterm split | terminal

" And all the regular vim things
if filereadable(glob("~/.vimrc"))
	source ~/.vimrc
endif

