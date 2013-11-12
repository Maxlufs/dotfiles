#!/usr/bin/env bash
#===========================================================================#
    # Filename: bootstrap.sh                                            #
    # Maintainer: Maximilian Q. Wang <maxlufs@gmail.com>                #
    # URL: https://github.com/Maxlufs/dotfiles                          #
#===========================================================================#
    # git clone                                                         #
    # git clone git@github.com:Maxlufs/dotfiles.git .dotfiles           #
    # cd dotfiles                                                       #
#===========================================================================#
    # Contents:                                                         #
    # 00. Variables                                                     #
    # 01. Clean up broken symlinks to ~/.dotfiles_old/                  #
    # 02. Backup old dotfiles to ~/.dotfiles_old/                       #
    # 04. Installing vim plugins                                        #
    # 03. Create symlinks to ~/.dotfiles/                               #
#===========================================================================#

#===========================================================================#
# TODO                                                                      #
# M: add bash 3.00 support                                                  #
# M: prompt users and ask if they what to git push for backup               #
# S: add report of system default env, eg. uname,bash,etc                   #
# S: git push backup (based on if ssh keys are generated)                   #
# S: copy vim :helptags locations                                           #
# S: only link files w/o extensions                                         #
# C: add a title of script output                                           #
# C: add progress bar while git clone/pull/push                             #
#===========================================================================#


#############################################################################
# Declare directory variables
#===========================================================================#
DOTFILEDIR=~/.dotfiles          # dotfiles dir
OLDDIR=~/.dotfiles_old          # dotfiles backup dir
VIMDIR=$DOTFILEDIR/vim          # vim dir
BUNDLEDIR=$VIMDIR/bundle        # vim plugin dir

# Declare vim plugin repo associate matrix
#===========================================================================#
declare -A repo                 

# vim colorschemes
repo["jellybeans"]="https://github.com/nanotech/jellybeans.vim.git"
repo["molokai"]="https://github.com/tomasr/molokai.git"
repo["wombat"]="https://github.com/vim-scripts/Wombat.git "
repo["wombat256"]="https://github.com/vim-scripts/wombat256.vim.git"

# vim plugins

PATHOGENREPO="https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
repo["easymotion"]="https://github.com/Lokaltog/vim-easymotion.git"
repo["nerdtree"]="https://github.com/scrooloose/nerdtree.git"
repo["powerline"]="https://github.com/Lokaltog/powerline.git"
repo["airline"]="https://github.com/bling/vim-airline.git"
#############################################################################


#############################################################################
# Welcome
#===========================================================================#
echo "=========================================="
echo ">>>        Starting bootstap...        <<<"
echo "=========================================="
#############################################################################

#############################################################################
# Clean up vim backup files
#===========================================================================#
shopt -s dotglob # list hidden files
find $DOTFILEDIR -name '*~' -delete
#############################################################################


#############################################################################
# Back up automatically to github
#===========================================================================#
echo ">>> Backing up to dotfiles.git... <<<" 
cd $DOTFILEDIR
git submodule init
git submodule update
git add .
git commit -am "automatic backup"
git push
#############################################################################

echo

#############################################################################
# Clean up broken symlinks
#===========================================================================#
shopt -s dotglob # list hidden files

# if [ -L $OLDDIR ]; then rm $OLDDIR; fi 
# There's the problem of .dotfiles_old become a link
if [ ! -d $OLDDIR ]; then mkdir -p $OLDDIR; fi

for f in ~/*
do
    if [ ! -e "$f" ]
    then
        echo ">>> Cleaning up broken link [$(basename "$f")] to dotfiles_old/... <<<"
        mv ~/$(basename "$f") $OLDDIR
        echo ">>> Cleanup completed <<<"
    fi
done

# Backing up old dotfiles
#===========================================================================#
for f in $DOTFILEDIR/*
do
    # if [ \( -L $f \) -a \( ! -e $f \) ] 
    # if file is a symlink and its broken
    if [ -e ~/.$(basename "$f") ]
    then
        echo ">>> Backing up old [$(basename "$f")] to dotfiles_old/... <<<"
        mv ~/.$(basename "$f") $OLDDIR
        echo ">>> Backup completed <<<"
    fi
done

shopt -u dotglob # unlist hidden files
#############################################################################

echo

#############################################################################
# Install pathogen
#===========================================================================#
mkdir -p $VIMDIR/autoload $VIMDIR/bundle;

echo ">>> Installing [Pathogen] for Vim... <<<" 
if [ ! -f "$VIMDIR/autoload/pathogen.vim" ]
then
    if [ ! $(which curl) ]; then sudo apt-get install -y curl; fi;
	curl -Sso $VIMDIR/autoload/pathogen.vim $PATHOGENREPO
	echo ">>> [Pathogen] installation completed. <<<"
else
	echo ">>> [Pathogen] already installed. <<<"
fi

# Install vim plugins with git submodules
#===========================================================================#
# cd ,dotfiles/

for i in "${!repo[@]}"      # support quotes for repo names w/ space in it.
do
    echo ">>> Installing [$i]... <<<" 
    # if [ \( -d $BUNDLEDIR/$i \) -a "$(ls -A $BUNDLEDIR/$i)" ]  
    # check if plugin dir exists
    # and there is something inside the plugin dir
    files=$(shopt -s nullglob dotglob; echo $BUNDLEDIR/$i/*)
    if (( ${#files} ))
    then
        echo ">>> [$i] already up-to-date <<<"
    else
        git submodule add ${repo[$i]} $BUNDLEDIR/$i -q # quite mode
        echo ">>> [$i] installation done <<<"
    fi
done

# Install vim plugins
#===========================================================================#
# cd $BUNDLEDIR
# 
# for i in "${!repo[@]}"      # support quotes for repo names w/ space in it.
# do
#     echo ">>> Installing [$i]... <<<" 
#     # if [ \( -d $BUNDLEDIR/$i \) -a "$(ls -A $BUNDLEDIR/$i)" ]  
#     # check if plugin dir exists
#     # and there is something inside the plugin dir
#     files=$(shopt -s nullglob dotglob; echo $i/*)
#     if (( ${#files} ))
#     then
#         cd $i 
#         git pull -q                 # quite mode
#         echo ">>> [$i] already up-to-date <<<"
#         cd ..
#     else
#         git clone ${repo[$i]} $i -q # quite mode
#         echo ">>> [$i] installation done <<<"
#     fi
# done
#############################################################################
    
echo

#############################################################################
# Creating symlinks
#===========================================================================#
echo ">>> Creating symbolic links... <<<" 
for f in $DOTFILEDIR/*
do
    echo ">>> Linking file [$(basename "$f")] <<<"
    ln -s $f ~/.$(basename "$f")
done
#############################################################################

echo
echo "=========================================="
echo ">>> Enjoy your new coding environment! <<<"
echo ">>>                          --Maxlufs <<<"
echo "=========================================="
