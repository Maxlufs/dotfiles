#!/usr/bin/env bash
#=========================================================================#
   # Filename: bootstrap.sh                                            #
   # Maintainer: Maximilian Q. Wang <maxlufs@gmail.com>                #
   # URL: https://github.com/Maxlufs/dotfiles                          #
#=========================================================================#
   # git clone                                                         #
   # git clone git@github.com:Maxlufs/dotfiles.git .dotfiles           #
   # cd dotfiles                                                       #
#=========================================================================#
   # Contents:                                                         #
   # 00. Variables & Fuctions                                          #
   # 01. Header                                                        #
   # 02. Broken symlinks          -> ~/.dotfiles_old/                  #
   # 03. Old dotfiles             -> ~/.dotfiles_old/                  #
   # 04. Vim plugins                                                   #
   # 05. Links                    -> ~/.dotfiles/                      #
   # 06. AutoBackup                                                    #
   # 07. Footer                                                        #
#=========================================================================#

#=========================================================================#
# TODO                                                                    #
# M: add bash 3.00 support                                                #
# M: prompt users and ask if they what to back up old files               #
# S: add report of system default env, eg. uname,bash,etc                 #
# S: git push backup (only when there is change in git diff)              #
# S: git push backup (based on if ssh keys are generated)                 #
# S: copy vim :helptags locations                                         #
# S: only link files w/o extensions                                  [OK] #
# C: add a Welcome title of script output                                 #
# C: add progress bar while git clone/pull/push                           #
#=========================================================================#


###########################################################################
# 00. Varibles & Functions
#=========================================================================#
# Declare directory variables
#=========================================================================#
DOTFILEDIR=~/.dotfiles          # dotfiles dir
OLDDIR=~/.dotfiles_old          # dotfiles backup dir
VIMDIR=vim                      # vim dir
BUNDLEDIR=vim/bundle            # vim plugin dir

# log_msg() function
# input  : (STATUS_MSG, COLOR, PREV_MSG)
# output : colored status in the same line with MSG
#=========================================================================#
log_msg() {

    STATUS=$1
    # tput setaf colors
    case $2 in
        BLACK ) COLOR=0
            ;;
        RED ) COLOR=1
            ;;
        GREEN ) COLOR=2
            ;;
        YELLOW ) COLOR=3
            ;;
        BLUE ) COLOR=4
            ;;
        MAGENTA ) COLOR=5
            ;;
        CYAN ) COLOR=6
            ;;
        WHITE ) COLOR=7
            ;;
    esac
    MSG=$3

    MAXCOL=70                   # MAXCOL=$(tput cols)
    OFFSET=4                    # This is for '<' or '<<<'
    NORMAL=$(tput sgr0)         # Normal color mode
    COLORSTATUS="$(tput setaf $COLOR)${STATUS}$NORMAL"

    let COL=$MAXCOL+${#COLORSTATUS}-$OFFSET-${#MSG}-${#STATUS}
    # tput cols = terminal width
    # 3 = <<<
    # MSG = $1
    # STATUS = text
    # COLORSTATUS = wrapped text

    if [[ ${#MSG} -ge ${COL} ]]
        # if MSG length too long, then print in new line
    then
        let COLFORLONG=$MAXCOL+${#COLORSTATUS}-$OFFSET-${#STATUS}
        # new line, need a new COL, i.e. ${#MSG} = 0
        printf "\n%${COLFORLONG}s"  "$COLORSTATUS"
    else
        printf "%${COL}s"  "$COLORSTATUS"
    fi
}

# Declare vim plugin repo associate matrix
#=========================================================================#
declare -A repo

# vim pathogen plugin
PATHOGENREPO="https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"

# vim colorschemes
repo["jellybeans"]="https://github.com/nanotech/jellybeans.vim.git"
repo["molokai"]="https://github.com/tomasr/molokai.git"
repo["wombat"]="https://github.com/vim-scripts/Wombat.git "
repo["wombat256"]="https://github.com/vim-scripts/wombat256.vim.git"

# vim ui plugins
repo["nerdtree"]="https://github.com/scrooloose/nerdtree.git"
repo["gundo"]="http://github.com/sjl/gundo.vim.git"
# repo["powerline"]="https://github.com/Lokaltog/powerline.git"
# use airline instead
repo["airline"]="https://github.com/bling/vim-airline.git"

# vim plugins
repo["easymotion"]="https://github.com/Lokaltog/vim-easymotion.git"
repo["fugitive"]="https://github.com/tpope/vim-fugitive.git"
repo["ctrlp"]="https://github.com/kien/ctrlp.vim.git"
# repo["indentguides"]="https://github.com/nathanaelkane/vim-indent-guides.git"
# use listchars instead
# repo["smarttabs"]="https://github.com/vim-scripts/Smart-Tabs.git"
# has conflict with listchars
repo["surround"]="https://github.com/tpope/vim-surround.git"

# vim ide plugins
repo["cvim"]="https://github.com:Maxlufs/c.vim.git"
# vim autocompletion plugin
repo["youcompleteme"]="https://github.com/Valloric/YouCompleteMe.git"
# vim snipmate dependecies
repo["snipmate"]="https://github.com/garbas/vim-snipmate.git"
repo["tlib"]="https://github.com/tomtom/tlib_vim.git"
repo["mwutils"]="https://github.com/MarcWeber/vim-addon-mw-utils.git"
repo["snippets"]="https://github.com/honza/vim-snippets.git"
###########################################################################

###########################################################################
# 01. Header
#=========================================================================#
echo "======================================================================"
echo ">>>                      Starting bootstrap...                     <<<"
echo ">>>         Your system envion :                                   <<<"
echo ">>>         Your shell version :                                   <<<"
echo "======================================================================"
###########################################################################

###########################################################################
# 02. Cleanup directory
#=========================================================================#
# Clean up vim backup files
#=========================================================================#
cd $DOTFILEDIR
shopt -s dotglob # list hidden files
find $DOTFILEDIR -name '*~' -delete

# Clean up broken symlinks
#=========================================================================#
echo ">>> Cleaning up broken symlinks to dotfiles_old/..."
shopt -s dotglob # list hidden files

# if [ -L $OLDDIR ]; then rm $OLDDIR; fi
# There's the problem of .dotfiles_old become a link
if [ ! -d $OLDDIR ]; then mkdir -p $OLDDIR; fi

for f in ~/*
do
    if [ ! -e "$f" ]
    then
        MSG="  > Cleaning up broken link [$(basename "$f")]..."
        printf "$MSG"
        mv ~/$(basename "$f") $OLDDIR
        log_msg "[OK]" "GREEN" "$MSG"
        printf " <\n"
    fi
done

log_msg "[OK]" "GREEN" ""
printf " <<<\n"

# echo "                                                    done <<<"
###########################################################################

echo "----------------------------------------------------------------------"

###########################################################################
# 03. Backing up old dotfiles
#=========================================================================#
echo ">>> Backing up old dotfiles to dotfiles_old/..."
for f in $DOTFILEDIR/*
do
    # if [ \( -L $f \) -a \( ! -e $f \) ]
    # if file is a symlink and its broken
    if [ -e ~/.$(basename "$f") ]
    then
        MSG="  > Backing up old [$(basename "$f")]..."
        printf "$MSG"
        mv ~/.$(basename "$f") $OLDDIR
        log_msg "[OK]" "GREEN" "$MSG"
        printf " <\n"
    fi
done

log_msg "[OK]" "GREEN" ""
printf " <<<\n"


shopt -u dotglob # unlist hidden files
###########################################################################

echo "----------------------------------------------------------------------"

###########################################################################
# 04. Vim plugins
#=========================================================================#
# Install pathogen
#=========================================================================#
MSG=">>> Installing [Pathogen] for Vim..."
printf "$MSG"

mkdir -p $VIMDIR/autoload $VIMDIR/bundle;

if [ ! -f "$VIMDIR/autoload/pathogen.vim" ]; then
	if [ ! $(which curl) ]; then sudo apt-get install -y curl; fi
	curl -Sso $VIMDIR/autoload/pathogen.vim $PATHOGENREPO
	log_msg "[Installation completed.]" "YELLOW" "$MSG"
	printf " <\n"
	#echo "                      [Pathogen] installation completed. <<<"
else
	#echo "                           [Pathogen] already installed. <<<"
	log_msg "[Already up-to-date]" "GREEN" "$MSG"
	printf " <\n"
fi
echo

# Install vim plugins with git submodules
#=========================================================================#
# cd .dotfiles/
# echo ">>> Installing Submodule plugins for Vim... <<<"
#
# # Had to remove .git/index to make sure submodules work
# # when vim/bundles dir is deleted.
# rm -f .git/index
#
# for i in "${!repo[@]}"      # support quotes for repo names w/ space in it.
# do
#     echo -ne "  > Installing [$i]... \t"
#     # if [ \( -d $BUNDLEDIR/$i \) -a "$(ls -A $BUNDLEDIR/$i)" ]
#     # check if plugin dir exists
#     # and there is something inside the plugin dir
#     files=$(shopt -s nullglob dotglob; echo $BUNDLEDIR/$i/*)
#     if (( ${#files} )) # if there is something inside $i dir
#     then
#         # git submodule -q update --init
#         # BUG here
#         echo "already up-to-date <"
#     else
#         # if there's nothing
#         rm -rf $BUNDLEFIR/$i
#         rm -rf .git/modules/$BUNDLEDIR/$i
#         git submodule -q add -f ${repo[$i]} $BUNDLEDIR/$i
#         # submodule's syntax, [--quiet] add [--force]
#         echo "installation done <"
#     fi
# done
#
# # git submodule -q init # combined into one
# git submodule -q update --init
#

# Install vim plugins
#=========================================================================#
cd $BUNDLEDIR
echo ">>> Installing Submodule plugins for Vim..."
for i in "${!repo[@]}"
    # support quotes for repo names w/ space in it.
do
    MSG="  > Installing [$i]... "
    printf "$MSG"
    # if [ \( -d $BUNDLEDIR/$i \) -a "$(ls -A $BUNDLEDIR/$i)" ]
    # check if plugin dir exists
    # and there is something inside the plugin dir
    files=$(shopt -s nullglob dotglob; echo $i/*)
    if (( ${#files} )) # if there is something inside $i dir
    then
        cd $i
        git pull -q                 # quite mode
        if [ "$(git diff HEAD)" ]; then
            git reset --hard -q origin/master
            # My misunderstanding of git pull.
            # need to use git reset in order to copy from commit to working dir
            log_msg "[Update done]" "YELLOW" "$MSG"
            # echo "already up-to-date <"
        else
            log_msg "[Already up-to-date]" "GREEN" "$MSG"
        fi
        printf " <\n"
        cd ..
    else
        git clone ${repo[$i]} $i -q # quite mode
        log_msg "[Installation done]" "YELLOW" "$MSG"
        printf " <\n"
    fi
done

log_msg "[OK]" "GREEN" ""
printf " <<<\n"
###########################################################################

echo "----------------------------------------------------------------------"

###########################################################################
# 05. Creating symlinks
#=========================================================================#
echo ">>> Creating symbolic links..."

shopt -s extglob
# had to use extended pattern matching syntax in bash
# looping over all files without extension, not yet perfect
for f in $DOTFILEDIR/!(*.*)
do
    MSG="  > Linking file [$(basename "$f")]..."
    printf "$MSG"
    ln -s $f ~/.$(basename "$f")
    log_msg "[OK]" "GREEN" "$MSG"
    printf " <\n"
done

log_msg "[OK]" "GREEN" ""
printf " <<<\n"
###########################################################################

echo "----------------------------------------------------------------------"

###########################################################################
# 06. Back up to github
#=========================================================================#
cd $DOTFILEDIR
defaultMsg="automatic backup"

echo ">>> Backing up to dotfiles.git..."
git add .
git add -u
echo "  > Changes to be committed:"
# git status -s
# print out all modified files with indent, awk might be easier
# need git config color.status always to pipe color to sed.
# But may have problems with vim-fugitive
git status -s | sed 's/^/    /'

if [[ $(git diff HEAD) ]]; then
    n=1
    while [ $n -le 3 ]; do
        read -p "  > Do you wish to back up to GitHub this time? [Y/n] " yn
        case $yn in
            [Yy]*|"" )
                echo "  > Please type in your commit message:"
                read -e -i "$defaultMsg" -p "    " subject # commit msg subject
                echo "  > Please type in your commit message body: [Press EOF to submit]"
                echo
                body=$(</dev/stdin)                        # commit msg body
                echo
                # git commit both subject and body
                git commit -m "$subject" -m "$body" | sed 's/^/  > /'
                # git push
                log_msg "[OK]" "GREEN" ""
                printf " <<<\n"
                break;;
            [Nn]* )
                break;;
            * )
                #echo "Unknown input"
                n=$(( n+1 ))
                ;;
        esac
    done
else
    echo "Nothing to commit (working directory clean)"
    log_msg "[OK]" "GREEN" ""
    printf " <<<\n"
fi

###########################################################################

###########################################################################
# 07. Footer
#=========================================================================#
echo "======================================================================"
echo ">>>               Enjoy your new coding environment!               <<<"
echo ">>>                                        --Maxlufs               <<<"
echo "======================================================================"
###########################################################################
