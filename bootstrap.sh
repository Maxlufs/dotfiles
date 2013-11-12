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
VIMDIR=vim                      # vim dir
BUNDLEDIR=vim/bundle            # vim plugin dir

MSG="$1"
RED=$(tput setaf 1)
GREEN=$(tput setaf 2) # len = 5
NORMAL=$(tput sgr0) # len = 6
STATUS="$GREEN[DONE]$NORMAL" # len = 17
let COL=$(tput cols)-${#STATUS}+${#GREEN}+${#NORMAL} 
# printf "%${COL}s" "$STATUS"
# current col - [DONE] + GREEN and NORMAL
# The let command carries out arithmetic operations on variables.

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
git add .
git commit -am "automatic backup"
git push
#############################################################################

echo "------------------------------------------"

#############################################################################
# Clean up broken symlinks
#===========================================================================#
echo ">>> Cleaning up broken symlinks to dotfiles_old..." 
shopt -s dotglob # list hidden files

# if [ -L $OLDDIR ]; then rm $OLDDIR; fi 
# There's the problem of .dotfiles_old become a link
if [ ! -d $OLDDIR ]; then mkdir -p $OLDDIR; fi

for f in ~/*
do
    if [ ! -e "$f" ]
    then
        echo -ne "  > Cleaning up broken link [$(basename "$f")]... \t"
        mv ~/$(basename "$f") $OLDDIR
        printf "%${COL}s\n" "$STATUS"
    fi
done
echo "                                         done <<<" 
#############################################################################

echo "------------------------------------------"

#############################################################################
# Backing up old dotfiles
#===========================================================================#
echo ">>> Backing up old dotfiles to dotfiles_old/..." 
for f in $DOTFILEDIR/*
do
    # if [ \( -L $f \) -a \( ! -e $f \) ] 
    # if file is a symlink and its broken
    if [ -e ~/.$(basename "$f") ]
    then
        echo -ne "  > Backing up old [$(basename "$f")]... \t"
        mv ~/.$(basename "$f") $OLDDIR
        printf "%${COL}s\n" "$STATUS"
    fi
done
echo "                                         done <<<" 

shopt -u dotglob # unlist hidden files
#############################################################################

echo "------------------------------------------"

#############################################################################
# Install pathogen
#===========================================================================#
echo -ne ">>> Installing [Pathogen] for Vim... \t" 

mkdir -p $VIMDIR/autoload $VIMDIR/bundle;

if [ ! -f "$VIMDIR/autoload/pathogen.vim" ]
then
    if [ ! $(which curl) ]; then sudo apt-get install -y curl; fi;
	curl -Sso $VIMDIR/autoload/pathogen.vim $PATHOGENREPO
	echo "[Pathogen] installation completed. <<<"
else
	echo "[Pathogen] already installed. <<<"
fi

# Install vim plugins with git submodules
#===========================================================================#
# cd .dotfiles/
echo
echo ">>> Installing Submodule plugins for Vim... <<<" 

git submodule init -q
git submodule update -q

for i in "${!repo[@]}"      # support quotes for repo names w/ space in it.
do
    echo -ne "  > Installing [$i]... \t" 
    # if [ \( -d $BUNDLEDIR/$i \) -a "$(ls -A $BUNDLEDIR/$i)" ]  
    # check if plugin dir exists
    # and there is something inside the plugin dir
    files=$(shopt -s nullglob dotglob; echo $BUNDLEDIR/$i/*)
    if (( ${#files} )) # if there is something inside $i dir
    then
        echo "[$i] already up-to-date <"
    else
        # if there's nothing
        rm -rf $BUNDLEFIR/$i
        git submodule add ${repo[$i]} $BUNDLEDIR/$i -q
        echo "[$i] installation done <"
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
    
echo "------------------------------------------"

#############################################################################
# Creating symlinks
#===========================================================================#
echo ">>> Creating symbolic links..." 
for f in $DOTFILEDIR/*
do
    echo -ne "  > Linking file [$(basename "$f")]... \t"
    ln -s $f ~/.$(basename "$f")
    printf "%${COL}s\n" "$STATUS"
done
echo "                                  done <<<"
#############################################################################

echo "=========================================="
echo ">>> Enjoy your new coding environment! <<<"
echo ">>>                          --Maxlufs <<<"
echo "=========================================="
