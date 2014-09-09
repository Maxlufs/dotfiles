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
    # 03. Vim plugins                                                   #
    # 04. Create symlinks          -> ~/.dotfiles/                      #
	# 05. AutoBackup (deprecated, invoke on flag)                       #
    # 06. Footer                                                        #
#============================================================================#

#============================================================================#
# TODO                                                                       #
# [ ] M: add bash 3.00 support: user `echo $0` and `echo $BASH_VERSION`      #
# [x] M: hide useless info if the user is not a first-time user              #
# [ ] S: add a list of system default env, eg. uname,bash,etc                #
# [x] S: git push backup (only when there is change in git diff)             #
# [ ] S: git push backup (based on if ssh keys are generated)                #
# [x] S: copy vim :helptags locations                                        #
# [x] S: only link files w/o extensions                                      #
# [x] C: add a Welcome title of script output                                #
# [ ] C: add progress bar while git clone/pull/push                          #
#============================================================================#

##############################################################################
# 00. Varibles & Functions
#============================================================================#
# exit if user is not using bash
#============================================================================#
if [ -n "$BASH_VERSION" ]; then
	bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
	# bmajor=${BASH_VERSINFO[0]}
	# bminor=${BASH_VERSINFO[1]}
	if [ $bmajor -lt 4 ]; then
		echo "Your shell is bash3, need add compatibility"
		exit
	fi
else
	echo "This script is only bash compatible."
	# need to figure out rbash compatibility problem, cuz rbash also has $BASH_VERSION
	exit
fi

# print_usage() function
# syntax: print_usage
# description: print out helper flags/options
#============================================================================#
print_usage() {
cat << EOF
usage: $0 options [-h]

-h		: Show this message
--pathogen	: Use pathogen to install vim plugins
--vundle	: Use vundel to install vim plugins
--print-only	: Dry run mode
--back-up	: Back up automatically to GitHub
--version	: Show version
EOF
}

# Declare flags
#============================================================================#
[[ $1 == "-h" ]] && print_usage && exit
[[ $1 == "--help" ]] && print_usage && exit
[[ $1 == "-p" ]] && print_only=1
[[ $1 == "--print-only" ]] && print_only=1
[[ $1 == "--pathogen" ]] && pathogen=1
[[ $1 == "--back-up" ]] && back_up=1

# Declare directory variables
#============================================================================#
DOTFILEDIR="$HOME/.dotfiles"          # dotfiles dir
OLDDIR="$HOME/.dotfiles_old"          # dotfiles backup dir
# if using ~ within quotes, cd $DIR won't work, need to use eval cd "$DIR"
VIMDIR="vim"                      # vim dir
BUNDLEDIR="vim/bundle"            # vim plugin dir (only used for git submodule)

# Declare terminal/shell width and color
#============================================================================#
# total_width = min{70, terminal_width}
terminal_width=`tput cols`
default_width=70
total_width=$(($default_width < $terminal_width ? $default_width : $terminal_width))

# delimiters
left_delimiter=">>>"
right_delimiter="<<<"

fgred="$(tput setaf 1)"
fggreen="$(tput setaf 2)"
fgyellow="$(tput setaf 3)"
fgblue="$(tput setaf 4)"
fgpurple="$(tput setaf 5)"
fgcyan="$(tput setaf 6)"
fgwhite="$(tput setaf 7)"

bgred="$(tput setab 1)"
bggreen="$(tput setab 2)"
bgyellow="$(tput setab 3)"
bgblue="$(tput setab 4)"
bgpurple="$(tput setab 5)"
bgcyan="$(tput setab 6)"
bgwhite="$(tput setab 7)"

bold="$(tput bold)"
underline="$(tput smul)"
reset="$(tput sgr0)"

# repeat()
# syntax: repeat "char" n
# description: repeat a single charater n times, with a newline at the end
#============================================================================#
repeat() {
	local c=$1
	local n=$2
	for i in $(seq $n)
	do
		printf "%s" "$c"
	done
	printf "\n"
}

# center()
# syntax: center leftDelimiter "str" rightDelimiter
# description: center "str" with delimiters on both side with a space
#============================================================================#
center() {
	local left="$1"
	local middle="$2"
	local right="$3"
	local left_len=${#left}
	local middle_len=${#middle}
	local right_len=${#right}
	let local sum_len=$left_len+$middle_len+$right_len+2
	# if the entire printed message length <= total_width, then center as usual
	if [ $sum_len -le $total_width ]
	then
		# floor if number if odd
		let local middle_start_pos=($total_width-$left_len+$middle_len-$right_len)/2
		#FIX the senario where number is odd
		let local right_start_pos=($total_width-$left_len-$middle_len+$right_len+1)/2
		printf "$left"
		printf "%${middle_start_pos}s" "$middle"
		printf "%${right_start_pos}s" "$right"
		printf "\n"
		# else if entire length > total width, but the middle msg <= total_width
		# print into 3 lines, center the msg on the second line.
	elif [ $middle_len -le $total_width ]
	then
		let local middle_start_pos=($total_width+$middle_len)/2
		let local right_start_pos=$total_width
		printf "$left"
		printf "\n"
		printf "%${middle_start_pos}s" "$middle"
		printf "\n"
		printf "%${right_start_pos}s" "$right"
		printf "\n"
		# else if middle msg > total_width, just print into 3 lines
		# let the middle line wrap by default
	else
		let local right_start_pos=$total_width
		printf "$left"
		printf "\n"
		printf "$middle"
		printf "\n"
		printf "%${right_start_pos}s" "$right"
		printf "\n"
	fi
}

# println()
# syntax: println "str1" "${fgyellow}str2" "str3"
# description: print colored msg
#============================================================================#
println() {
# set counter of currently printed length to 0
local curr_len=0

# looping from the first paramter to the second last (ie. $#-1)
for var in "${@:1:$#-1}"
do
	printf "$var"
	# increment the curr_len by adding each parameter's length
	let curr_len=$curr_len+${#var}
done

# special dealing with the last argument, typically for alignment
last_arg="${!#}"
last_arg_len=${#last_arg}

# length of whitespaces left
let rest_len=$total_width-$curr_len

# if the length of rest whitespace is less than " <<<", print " <<<" in newline
if [ $rest_len -lt $(($last_arg_len + 1)) ] # plus 1 is for the space before <
then
	let rest_len=$total_width
	printf "\n"
	printf "%${rest_len}s\n" $last_arg
else
	printf "%${rest_len}s\n" $last_arg
fi

}

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

	OFFSET=4                    # This is for '<' or '<<<'
	NORMAL=$(tput sgr0)         # Normal color mode
	COLORSTATUS="$(tput setaf $COLOR)${STATUS}$NORMAL"

	let COL=$total_width+${#COLORSTATUS}-$OFFSET-${#MSG}-${#STATUS}
	# tput cols = terminal width
	# 3 = <<<
	# MSG = $1
	# STATUS = text
	# COLORSTATUS = wrapped text

	if [[ ${#MSG} -ge ${COL} ]]
		# if MSG length too long, then print in new line
	then
		let COLFORLONG=$total_width+${#COLORSTATUS}-$OFFSET-${#STATUS}
		# new line, need a new COL, i.e. ${#MSG} = 0
		printf "\n%${COLFORLONG}s"  "$COLORSTATUS"
	else
		printf "%${COL}s"  "$COLORSTATUS"
	fi

	# This is an example to use printf to print out color directly
    # if [ "${EXITSTATUS}" -eq 0 ]
    # then
    #    printf "\e[1;32m%$(($COLUMNS))s\e[m" "[  OK  ] "
    # else
    #    printf "\e[1;31m%$(($COLUMNS))s\e[m" "[ERRORS] "
    # fi
}

# Declare pathogen vim plugin repo associate matrix
#============================================================================#
if [[ $pathogen ]]; then
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
fi
##############################################################################

##############################################################################
# 01. Header
#============================================================================#
repeat "=" $total_width
center $left_delimiter "Starting bootstrap..." $right_delimiter
center $left_delimiter "Your system envion: $(uname -np)" $right_delimiter
center $left_delimiter "Your shell version: ${BASH_VERSION}" $right_delimiter
repeat "=" $total_width
##############################################################################

##############################################################################
# 02. Backing up old dotfiles
#============================================================================#
# Only backup original dotfiles if .dotfiles_old dir doesn't exist
if [ ! -d $OLDDIR ]
then
	first_time=1
	echo ">>> Backing up original dotfiles to dotfiles_old/..."
	# There's the problem of .dotfiles_old become a symlink
	# so if .dotfiles_old is a symlink, remove it
	if [ -L $OLDDIR ]; then rm $OLDDIR -f; fi
	# create backup directory if not existing
	[[ $print_only ]] || mkdir -p $OLDDIR > /dev/null

	for f in $DOTFILEDIR/*
	do
		filename=$(basename "$f")
		# backup the original actual file, even it's a symlink
		if [ -f $HOME/.$filename ]
		then
			MSG="  > Backing up original [$filename]..."
			printf "$MSG"
			[[ $print_only ]] || mv $HOME/.$filename $OLDDIR
			log_msg "[OK]" "GREEN" "$MSG"
			printf " <\n"
		fi
	done
log_msg "[OK]" "GREEN" ""
printf " <<<\n"

# Clean up broken symlinks in home directory
#============================================================================#
# shopt -s dotglob # list hidden files

# find under $HOME. if there is no broken symlink, skip to end, otherwise fix it.
# [[ -z $(find -L ~ -maxdepth 1 -type l 2> /dev/null) ]]

repeat "-" $total_width
fi
##############################################################################

##############################################################################
# 04. VIM plugins
#============================================================================#
# Install pathogen
#============================================================================#
if [[ $pathogen ]]; then

	MSG=">>> Installing [Pathogen] for Vim..."
	printf "$MSG"

	mkdir -p $VIMDIR/autoload $VIMDIR/bundle;

	if [ ! -f "$VIMDIR/autoload/pathogen.vim" ]; then
		[[ $print_only ]] || [[ $(command -v curl) ]] || sudo apt-get install -y curl
		[[ $print_only ]] || curl -Sso $VIMDIR/autoload/pathogen.vim $PATHOGENREPO
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

repeat "-" $total_width
fi

# Patching font
# fc-cache -vf ~/.fonts
#============================================================================#
##############################################################################

##############################################################################
# 05. Creating symlinks (main part)
#============================================================================#
echo ">>> Creating symbolic links..."

# Clean up vim backup files in dotifiles_dir
# user may change files and leave vim backup files
# otherwise bootstrap.sh will create symlinks to these hidden files
#============================================================================#
shopt -s dotglob # list hidden files
[[ $print_only ]] || find $DOTFILEDIR -name '*~' -delete 2> /dev/null
shopt -u dotglob # unlist hidden files

# looping over all files without extension
# find . -maxdepth 1 -type f ! -name "*.*"
for f in $DOTFILEDIR/*
do
	filename=$(basename "$f")
	if [[ ! $filename == *.* ]]
	then
		MSG="  > Linking file [$filename]..."
		printf "$MSG"
		# remove the old symlinks before linking, deal with the case dotfile_old
		# exists, but symlink is broken
		[[ $print_only ]] || rm $HOME/.$filename -rf
		[[ $print_only ]] || ln -s $f $HOME/.$filename
		log_msg "[OK]" "GREEN" "$MSG"
		printf " <\n"
	fi
done

log_msg "[OK]" "GREEN" ""
printf " <<<\n"
##############################################################################

##############################################################################
# 06. Back up to github
#============================================================================#
if [[ $back_up ]]; then

	repeat "-" $total_width

	echo ">>> Backing up to dotfiles.git..."
	defaultMsg="automatic backup"

	cd $DOTFILEDIR
	git add .
	git add -u
	echo "  > Changes to be committed:"
	# git status -s
	# print out all modified files with indent, awk might be easier
	# need git config color.status always to pipe color to sed.
	# But may have problems with vim-fugitive
	git status -s | sed 's/^/    /'

	[[ $print_only ]] && exit

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

fi
##############################################################################

##############################################################################
# 07. Footer
#============================================================================#
repeat "=" $total_width
center $left_delimiter "Enjoy your new coding environment!" $right_delimiter
center $left_delimiter "                         --Maxlufs" $right_delimiter
repeat "=" $total_width
##############################################################################
if [[ $first_time ]]; then
echo "original dotfiles can be found in $OLDDIR"
fi
