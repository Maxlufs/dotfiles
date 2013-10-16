#!/usr/bin/env bash
# #####################################################
# git clone
# git clone git@github.com:Maxlufs/dotfiles.git
# cd dotfiles
# #####################################################
# ./bootstrap.sh
# This script creates symlinks from home/ to .dotfiles/
# #####################################################


# ###################################################################
# TODO
# M: duplicate git clone prob. double run the script w/o error
# M: symlink prob 
# S: git push backup
# C: copy vim :helptags locations

# directory variables
DOTFILEDIR=~/dotfiles                     # dotfiles dir
OLDDIR=~/dotfiles_old              # dotfiles backup dir
VIMDIR=~/dotfiles/vim              # vim dir
BUNDLEDIR=~/dotfiles/vim/bundle    # vim plugin dir

mkdir -p $DOTFILEDIR
# Cleaning broken links
shopt -s dotglob # list hidden files
for f in ~/*
do
    if [ \( -L $f \) -a \( ! -e $f \) ] # if file is a symlink and its broken
    then
        if [ ! -d $OLDIR ]; then mkdir -p $OLDDIR; fi
        echo "Backing up $f to $OLDDIR..."
        mv $f $OLDDIR
        echo "...done"
    fi
done


# #################################################################
# vim colorschemes
declare -A repo
repo["jellybeans"]="https://github.com/nanotech/jellybeans.vim.git"
repo["molokai"]="https://github.com/tomasr/molokai.git"
repo["wombat"]="https://github.com/vim-scripts/Wombat.git "
repo["wombat256"]="https://github.com/vim-scripts/wombat256.vim.git"
# #################################################################
# vim plugins
PATHOGENREPO="https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
repo["easymotion"]="https://github.com/Lokaltog/vim-easymotion.git"
repo["nerdtree"]="https://github.com/scrooloose/nerdtree.git"
repo["powerline"]="https://github.com/Lokaltog/powerline.git"
# #################################################################


# #################################################################

# vim pathogen
mkdir -p $VIMDIR/autoload $VIMDIR/bundle;

echo ">>> Installing [Pathogen] for Vim... <<<" 
if [ ! -f "$VIMDIR/autoload/pathogen.vim" ]
then
	curl -Sso ~/.dotfiles/vim/autoload/pathogen.vim $PATHOGENREPO
	echo ">>> [Pathogen] installation completed. <<<"
else
	echo ">>> [Pathogen] already installed. <<<"
fi

# git clone repos
cd $BUNDLEDIR

for i in "${!repo[@]}" # add quotes for repo names w/ space in it.
do
    echo ">>> Installing [$i]... <<<" 
    if [ -d $BUNDLEDIR/$i ]
    then
        cd $BUNDLEDIR/$i 
        git pull
        echo ">>> [$i] already up-to-date <<<"
    else
        git clone ${repo[$i]} $i
        echo ">>> [$i] installation done <<<"
    fi
done
    

# git push dotfiles.git for backup
cd $DOTFILEDIR
echo ">>> Backing up dotfiles.git... <<<" 
# git add .
# git commit -am "regular backup"
# git push

# Creating symlinks

echo ">>> Creating symbolic links... <<<" 
for f in $DOTFILEDIR/*
do
    echo ">>> Linking file [$(basename "$f")] <<<"
    ln -s $f ~/.$(basename "$f")
done
