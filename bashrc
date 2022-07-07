#!/bin/bash

if [ -f /etc/bash.bashrc ]; then
    source /etc/bash.bashrc
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Color prompt with version control branch name
__vcprompt=""
if [ -f /usr/share/git/git-prompt.sh ]; then
    source /usr/share/git/git-prompt.sh
    __vcprompt="$__vcprompt"'$(__git_ps1)'
elif [ -f /etc/bash_completion.d/git-prompt ]; then
    source /etc/bash_completion.d/git-prompt
    __vcprompt="$__vcprompt"'$(__git_ps1)'
fi

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    PROMPT_COLOR='\e[1;33m'
elif [ -n "$container" ]; then
    PROMPT_COLOR='\e[1;37m'
else
    PROMPT_COLOR='\e[1;32m'
fi
PS1='\['"$PROMPT_COLOR"'\][\u@\h \W\[\033[1;36m\]'"$__vcprompt"'\['"$PROMPT_COLOR"'\]]\$\[\e[0m\] '

# CNF
if [ -f /usr/share/doc/pkgfile/command-not-found.bash ]; then
    source /usr/share/doc/pkgfile/command-not-found.bash
fi

# Autojump
if [ -f /etc/profile.d/autojump.sh ]; then
    source /etc/profile.d/autojump.sh
elif [ -f /usr/share/autojump/autojump.bash ]; then
    source /usr/share/autojump/autojump.bash
fi

# Bash completion (stolen from Ubuntu's skeleton bashrc)
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Editor
if [ ! -z $(type -p nvim) ]; then
    export EDITOR="nvim"
else
    export EDITOR="vim"
fi

# Calculate with C-q, from http://askubuntu.com/a/379615/96292
bind '"\C-q": "\C-aqalc \C-m"'

function ups() {
    if [ $# -eq 0 ]; then
        echo "`basename "$0"`: specify a number" >&2
        return 1
    fi
    eval printf '../%.s' {1.."$1"}
}
function up() {
    local cwd="$PWD"
    if [ $# -eq 0 ]; then
        local lev=0
        while [ "$cwd" ]; do
            expand -t3 <<< "$lev	-> $cwd"
            cwd=${cwd%/*}
            lev=$((lev+1))
        done
        expand -t3 <<< "$lev	-> /"
    else
        local lev="$1"
        UPDIR="$PWD"
        cd $(ups $1)
    fi
}
function down() {
    if [[ "$UPDIR" && "$UPDIR" == $PWD* ]]; then
        cd "$UPDIR"
    else
        echo "`basename -- $0`: can't go down" >&2
        return 127
    fi
}

# Miscellaneous bindings
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias -- -='cd -'
function dammit() {
	shuf -n1 <<- EOF
		Okay, okay.
		You don't have to yell.
		Everyone remain calm.
		Let's keep it down over here.
		Look buddy, I don't want any trouble here.
		Ever heard of 'please'?
		Next time just use 'sudo' from the get-go.
		You're the boss!
		EOF
	last_cmd="$(history -p \!\!)"
	history -d "$(history 1 | awk '{print $1}')" && history -s "sudo $last_cmd"
	sudo "$last_cmd"
}
function mdcd() { if [ -z "$1" ]; then return; fi; mkdir -p "$1" && cd "$1"; }
# GNU ls would say --color=auto; BSD says -G
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias ls='ls -x --color=auto'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls='ls -Gx'
fi

alias ll='ls -lh'
alias cpr='cp -r'
alias dfh='df -h'
alias kill9='kill -9'
alias clip='xsel --clipboard'
alias ipy=ipython
alias ipy3=ipython3

# Convenient and more memorable alias for combine (from moreutils)
alias _=combine

# Less should scroll with the mouse wheel, and trim long lines
export LESS=" -rS"

# '[r]emove [o]rphans' - recursively remove ALL orphaned packages
alias pacro="/usr/bin/pacman -Qtdq > /dev/null && sudo /usr/bin/pacman -Rs \$(/usr/bin/pacman -Qtdq | sed -e ':a;N;\$!ba;s/\n/ /g')"

# Various shell settings:

# Even on systems without autocomplete, it's nice to have cd only autocomplete directories:
complete -d cd
# and don't tab-complete .hidden_files
bind 'set match-hidden-files off'

# Ignore space commands and repeated commands from history
export HISTCONTROL=ignoreboth
export HISTFILESIZE=500000
export HISTSIZE=500000

# tabs should be 4 chars long
tabs 4

# Enable checkwinsize to prevent garbage line-wrapping
shopt -s checkwinsize

# Local customizations allowed and encouraged!
if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi

# Fortune! (if available)
fortune 2> /dev/null

complete -d cd

export PATH=$HOME/.toolbox/bin:$PATH
