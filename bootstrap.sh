#!/usr/bin/env bash
#============================================================================#
    # Filename: bootstrap.sh                                            #
    # Maintainer: Maximilian Q. Wang <maxlufs@gmail.com>                #
    # URL: https://github.com/Maxlufs/dotfiles                          #
#============================================================================#
    # git clone                                                         #
    # git clone git@github.com:Maxlufs/dotfiles.git .dotfiles           #
    # cd dotfiles                                                       #
#============================================================================#
    # Contents:                                                         #
    # 00. Variables & Fuctions                                          #
    # 01. Header                                                        #
    # 02. Old dotfiles             -> ~/.dotfiles_old/                  #
    # 03. Broken symlinks          -> ~/.dotfiles_old/                  #
    # 04. Vim plugins                                                   #
    # 05. Links                    -> ~/.dotfiles/                      #
    # 06. AutoBackup                                                    #
    # 07. Footer                                                        #
#============================================================================#

#============================================================================#
# TODO                                                                       #
# [ ] M: add bash 3.00 support: user `echo $0` and `echo $BASH_VERSION`      #
# [ ] M: prompt users and ask if they what to back up old files              #
# [ ] S: add a list of system default env, eg. uname,bash,etc                #
# [*] S: git push backup (only when there is change in git diff)             #
# [ ] S: git push backup (based on if ssh keys are generated)                #
# [*] S: copy vim :helptags locations                                        #
# [*] S: only link files w/o extensions                                      #
# [ ] C: add a Welcome title of script output                                #
# [ ] C: add progress bar while git clone/pull/push                          #
#============================================================================#

##############################################################################
# 00. Varibles & Functions
#============================================================================#
# Declare directory variables
#============================================================================#
DOTFILEDIR="$HOME/.dotfiles"          # dotfiles dir
OLDDIR="$HOME/.dotfiles_old"          # dotfiles backup dir
# if using ~ within quotes, cd $DIR won't work, need to use eval cd "$DIR"
VIMDIR="vim"                      # vim dir
BUNDLEDIR="vim/bundle"            # vim plugin dir

if [ -n "$BASH_VERSION" ]; then
	echo "Bash version: $BASH_VERSION"
	bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
	# bmajor=${BASH_VERSINFO[0]}
	# bminor=${BASH_VERSINFO[1]}
	if [ $bmajor -lt 4 ]; then
		echo "Your shell is bash3, need add compatibility"
		exit
	fi
	#exit
else
	echo "You're using $0. This script is only bash compatible."
	# need to figure out rbash compatibility problem, cuz rbash also has $BASH_VERSION
	exit
fi

# log_msg() function
# input  : (STATUS_MSG, COLOR, PREV_MSG)
# output : colored status in the same line with MSG
#============================================================================#
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

    # if [ "${EXITSTATUS}" -eq 0 ]
    # then
    #    printf "\e[1;32m%$(($COLUMNS))s\e[m" "[  OK  ] "
    # else
    #    printf "\e[1;31m%$(($COLUMNS))s\e[m" "[ERRORS] "
    # fi
}

# Declare vim plugin repo associate matrix
#============================================================================#
declare -A repo

# vim pathogen plugin
PATHOGENREPO="https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"
# repo["vundle"]="https://github.com/gmarik/vundle.git"

# vim colorschemes
# ================
repo["jellybeans"]="https://github.com/nanotech/jellybeans.vim.git"
repo["molokai"]="https://github.com/tomasr/molokai.git"
repo["wombat"]="https://github.com/vim-scripts/Wombat.git "
repo["wombat256"]="https://github.com/vim-scripts/wombat256.vim.git"

# vim ui plugins
# ==============
repo["nerdtree"]="https://github.com/scrooloose/nerdtree.git"
repo["gundo"]="http://github.com/sjl/gundo.vim.git"
repo["airline"]="https://github.com/bling/vim-airline.git"
# repo["powerline"]="https://github.com/Lokaltog/powerline.git"
# use airline instead
repo["gitgutter"]="https://github.com/airblade/vim-gitgutter.git"

# vim text plugins
# ================
repo["easymotion"]="https://github.com/Lokaltog/vim-easymotion.git"
repo["surround"]="https://github.com/tpope/vim-surround.git"
repo["matchit"]="https://github.com/vim-scripts/matchit.zip.git"
repo["nerdcommenter"]="https://github.com/scrooloose/nerdcommenter.git"
repo["tabular"]="https://github.com/godlygeek/tabular.git"
# repo["indentguides"]="https://github.com/nathanaelkane/vim-indent-guides.git"
# use listchars instead
# repo["smarttabs"]="https://github.com/vim-scripts/Smart-Tabs.git"

# vim IDE plugins
repo["vim-latex"]="https://github.com/Maxlufs/vim-latex.git"
repo["syntastic"]="https://github.com/scrooloose/syntastic.git"
repo["fugitive"]="https://github.com/tpope/vim-fugitive.git"
repo["ctrlp"]="https://github.com/kien/ctrlp.vim.git"
# repo["cvim"]="https://github.com/Maxlufs/c.vim.git"
# cvim is too giant
repo["vim-hdevtools"]="https://github.com/bitc/vim-hdevtools.git"
# zen coding
repo["sparkup"]="https://github.com/rstacruz/sparkup.git"
# JavaScript indent
repo["jsindent"]="https://github.com/pangloss/vim-javascript.git"


# vim autocompletion plugin
repo["youcompleteme"]="https://github.com/Valloric/YouCompleteMe.git"

# vim ultisnips
repo["ultisnips"]="https://github.com/SirVer/ultisnips.git"

# vim snipmate dependecies
# repo["snipmate"]="https://github.com/garbas/vim-snipmate.git"
# repo["tlib"]="https://github.com/tomtom/tlib_vim.git"
# repo["mwutils"]="https://github.com/MarcWeber/vim-addon-mw-utils.git"
# repo["snippets"]="https://github.com/honza/vim-snippets.git"
##############################################################################

##############################################################################
# 01. Header
#============================================================================#
echo "======================================================================"
echo ">>>                      Starting bootstrap...                     <<<"
echo ">>>         Your system envion :                                   <<<"
echo ">>>         Your shell version :                                   <<<"
echo "======================================================================"
##############################################################################

##############################################################################
# 02. Backing up old dotfiles
#============================================================================#
echo ">>> Backing up original dotfiles to dotfiles_old/..."

# Only backup original dotfiles if .dotfiles_old dir doesn't exist
if [ ! -d $OLDDIR ]
then

	# There's the problem of .dotfiles_old become a symlink
	if [ -L $OLDDIR ]; then rm $OLDDIR -f; fi
	# create backup directory if not exist
	mkdir -p $OLDDIR > /dev/null

	for f in $DOTFILEDIR/*
	do
		filename=$(basename "$f")
		# backup the original actual file, even it's a symlink
		if [ -f ~/.$filename ]
		then
			MSG="  > Backing up original [$filename]..."
			printf "$MSG"
			mv ~/.$(basename "$f") $OLDDIR
			log_msg "[OK]" "GREEN" "$MSG"
			printf " <\n"
		fi
	done
fi

log_msg "[OK]" "GREEN" ""
printf " <<<\n"
##############################################################################

echo "----------------------------------------------------------------------"

##############################################################################
# 03. Cleanup directory
#============================================================================#
# Clean up vim backup files
#============================================================================#
cd $DOTFILEDIR
shopt -s dotglob # list hidden files
find $DOTFILEDIR -name '*~' -delete 2> /dev/null

# Clean up broken symlinks
#============================================================================#
echo ">>> Cleaning up broken symlinks to dotfiles_old/..."
# shopt -s dotglob # list hidden files

# find under $HOME. if there is no broken symlink, skip to end, otherwise fix it.
# [[ -z $(find -L ~ -maxdepth 1 -type l 2> /dev/null) ]]

# Find broken symlinks in $HOME directory and cleaning up to $OLDDIR
for f in ~/*
do
	if [ ! -e "$f" ] # check if the file a symlink points to exists
	then
		filename=$(basename "$f")
		MSG="  > Cleaning up broken link [$filename]..."
		printf "$MSG"
		mv ~/$(basename "$f") $OLDDIR
		log_msg "[OK]" "GREEN" "$MSG"
		printf " <\n"
	fi
done

log_msg "[OK]" "GREEN" ""
printf " <<<\n"

shopt -u dotglob # unlist hidden files
##############################################################################

echo "----------------------------------------------------------------------"

##############################################################################
# 04. VIM plugins
#============================================================================#
# Install pathogen
#============================================================================#
MSG=">>> Installing [Pathogen] for Vim..."
printf "$MSG"

mkdir -p $VIMDIR/autoload $VIMDIR/bundle;

if [ ! -f "$VIMDIR/autoload/pathogen.vim" ]; then
	[[ $(command -v curl) ]] || sudo apt-get install -y curl
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
#============================================================================#
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
#============================================================================#

#cd $BUNDLEDIR
#echo ">>> Installing Submodule plugins for Vim..."
#for i in "${!repo[@]}"
	## support quotes for repo names w/ space in it.
#do
	#MSG="  > Installing [$i]... "
	#printf "$MSG"
	## if [ \( -d $BUNDLEDIR/$i \) -a "$(ls -A $BUNDLEDIR/$i)" ]
	## check if plugin dir exists
	## and there is something inside the plugin dir
	#files=$(shopt -s nullglob dotglob; echo $i/*)
	#if (( ${#files} )) # if there is something inside $i dir
	#then
		#cd $i
		#git pull -q                 # quite mode
		#if [[ $(git diff HEAD) ]]; then
			#git reset --hard -q origin/master
			## My misunderstanding of git pull.
			## need to use git reset in order to copy from commit to working dir
			#log_msg "[Update done]" "YELLOW" "$MSG"
			## echo "already up-to-date <"
		#else
			#log_msg "[Already up-to-date]" "GREEN" "$MSG"
		#fi
		#printf " <\n"
		#cd ..
	#else
		#git clone ${repo[$i]} $i -q # quite mode
		#log_msg "[Installation done]" "YELLOW" "$MSG"
		#printf " <\n"
	#fi
#done

log_msg "[OK]" "GREEN" ""
printf " <<<\n"

# Patching font
# fc-cache -vf ~/.fonts
#============================================================================#
##############################################################################

echo "----------------------------------------------------------------------"

##############################################################################
# 05. Creating symlinks
#============================================================================#
echo ">>> Creating symbolic links..."

# looping over all files without extension
# find . -maxdepth 1 -type f ! -name "*.*"
for f in $DOTFILEDIR/*
do
	filename=$(basename "$f")
	if [[ ! $filename == *.* ]]
	then
		MSG="  > Linking file [$filename]..."
		printf "$MSG"
		rm $HOME/.$filename -rf # remove the old symlinks before linking
		ln -s $f $HOME/.$filename
		log_msg "[OK]" "GREEN" "$MSG"
		printf " <\n"
	fi
done

log_msg "[OK]" "GREEN" ""
printf " <<<\n"
##############################################################################

echo "----------------------------------------------------------------------"

##############################################################################
# 06. Back up to github
#============================================================================#
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
        read -p "  > Do you wish to commit this time? [Y/n] " yn
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
##############################################################################

##############################################################################
# 07. Footer
#============================================================================#
echo "======================================================================"
echo ">>>               Enjoy your new coding environment!               <<<"
echo ">>>                                        --Maxlufs               <<<"
echo "======================================================================"
##############################################################################
