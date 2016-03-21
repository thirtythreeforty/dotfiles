source ~/.vim/config/base.vim
source ~/.vim/config/mappings.vim
source ~/.vim/config/autocmd.vim
source ~/.vim/config/plugins.vim

" Local hook:
if filereadable(glob("~/.vimrc_local"))
	source ~/.vimrc_local
endif
