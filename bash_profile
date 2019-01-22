export PATH=$HOME/bin:$HOME/bin_local:$HOME/.local/bin:$HOME/.node_modules/bin:$PATH

if [ -f ~/.bash_profile_local ]; then
	source ~/.bash_profile_local
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
