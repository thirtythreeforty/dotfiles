export PATH=$HOME/bin:$HOME/bin_local:$HOME/.local/bin:$HOME/.node_modules/bin:$PATH

# https://support.apple.com/en-us/HT208050
export BASH_SILENCE_DEPRECATION_WARNING=1

if [ -f ~/.bash_profile_local ]; then
	source ~/.bash_profile_local
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
