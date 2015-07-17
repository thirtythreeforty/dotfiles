# dotfiles

This is my dotfiles repository.
There are many like it, but this one is mine.

## Setup

I'm using the excellent [DotBot](https://github.com/anishathalye/dotbot) to manage everything so setup is super simple.
Just clone this repository and run its `install` script from your home directory.
You'll need Git and Python installed.
You can copy and paste:

    cd ~
    git clone https://github.com/thirtythreeforty/dotfiles
    dotfiles/install

## Customization

I don't provide many hooks for further customization; I'm a firm believer that dotfiles should be personal.
Just fork my dotfiles if you have something to add!

That said, there are a couple hooks present in case you have machine-specific things to add.  They are:

 - `.bashrc_local`: For Bash.  Runs after the main `.bashrc` script.
 - `.vimrc_local`: For Vim.  Runs after the main `.vimrc` config is parsed and after all plugins are loaded.
