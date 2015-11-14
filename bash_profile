export PATH=~/bin:~/bin_local:$PATH

# Help for Racer which is in dotfiles
export PATH=$PATH:~/dotfiles/racer/target/release

if [ -f ~/.bash_profile_local ]; then
	source ~/.bash_profile_local
fi
