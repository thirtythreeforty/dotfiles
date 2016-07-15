export PATH=~/bin:~/bin_local:~/.node_modules/bin:$PATH

if [ -f ~/.bash_profile_local ]; then
	source ~/.bash_profile_local
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
