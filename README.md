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

You should be able to pull all changes by simply rerunning the installer script.

## Customization

I don't provide many hooks for further customization; I'm a firm believer that dotfiles should be personal.
Just fork my dotfiles if you have something to add!

That said, there are a couple hooks present in case you have machine-specific things to add.  They are:

 - `.bashrc_local`: For Bash.  Runs after the main `.bashrc` script.
 - `bin_local/`: A directory in which you can add additional commands, like `bin/`.
 - `.spacemacs_local`: For Emacs.  This file is loaded directly after `spacemacs/user-config`, so code in this file is run directly after that function.
 - `.gitconfig_local`: For Git.  Loaded after the main `.gitconfig` is parsed.
 - `.inputrc_local`: For Readline.  Sourced after the main `.inputrc` configuration.
 - `.vimrc_local`: For Vim.  Runs after the main `.vimrc` config is parsed and after all plugins are loaded.

### Vim submodules

Because adding plugins to use with Pathogen is a little harder when they're tracked as submodules (don't run `git clone` like if you're not using dotfiles!), you can use the convenient command:

    add-vim-plugin http://path/to/repo

It will add the plugin to your dotfiles repo as a submodule and check it out for you.
You must commit the new submodule yourself.
There is also the corresponding command to remove a plugin:

    remove-vim-plugin plugin-name

(You can pass the original URL too.)
This will remove the plugin's directory and remove it as a submodule from the dotfiles repo.

Finally, you can update all plugins in one fell swoop with:

    update-vim-plugins

This walks over each element in `~/dotfiles/vim/bundle` and fetches and checks out `origin/HEAD`.
