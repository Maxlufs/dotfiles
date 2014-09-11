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
# [ ] M: use getopts to handle script flags                                  #
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
# 00. Varibles & Helper Functions
#============================================================================#
VERSION="v1.2-Sep.9.2014"

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
unset bash bmajor bminor

# Declare directory variables
#============================================================================#
DOTFILEDIR="$HOME/.dotfiles"          # dotfiles dir
OLDDIR="$HOME/.dotfiles_old"          # dotfiles backup dir
# if using ~ within quotes, cd $DIR won't work, need to use eval cd "$DIR"
VIMDIR="$DOTFILEDIR/vim"                      # vim dir
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

# print_usage() function
# syntax: print_usage
# description: print out helper flags/options
#============================================================================#
print_usage() {
cat << EOF
Version: $VERSION
Usage: $0 options [--pathogen] [--vundle] [--debug] [-f|-d] file

	-f FILE		: install dotfile FILE
	-d FILE		: uninstall dotfile FILE
	-h --help	: show this message
	--backup	: back up automatically to GitHub (not perfect)
	--pathogen	: use pathogen to install vim plugins (not perfect)
	--print-only	: dry run mode, only print out ui for debugging
	--version	: show version only
	--vundle	: use vundle to install vim plugins (not implemented)
	--uninstall	: uninstall all dotfile
EOF
}

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
	# if unset i here, if repeat is running inside another loop, i from the
	# outer loop will be unset, will need to wrap repeat function within
	# parantheses
	#unset i
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
	local STATUS=$1
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
	local MSG=$3

	local OFFSET=4                    # This is for '<' or '<<<'
	local NORMAL=$(tput sgr0)         # Normal color mode
	local COLORSTATUS="$(tput setaf $COLOR)${STATUS}$NORMAL"

	let local COL=$total_width+${#COLORSTATUS}-$OFFSET-${#MSG}-${#STATUS}
	# tput cols = terminal width
	# 3 = <<<
	# MSG = $1
	# STATUS = text
	# COLORSTATUS = wrapped text

	if [[ ${#MSG} -ge ${COL} ]]
		# if MSG length too long, then print in new line
	then
		let local COLFORLONG=$total_width+${#COLORSTATUS}-$OFFSET-${#STATUS}
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
if (( $pathogen_f )); then
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
# print_header()
# syntax: print_header
# description: print out welcome header, host system environ
print_header() {
repeat "=" $total_width
center $left_delimiter "Starting bootstrap..." $right_delimiter
center $left_delimiter "Your system envion: $(uname -np)" $right_delimiter
center $left_delimiter "Your shell version: ${BASH_VERSION}" $right_delimiter
repeat "=" $total_width
}
##############################################################################

##############################################################################
# 02. Backing up old dotfiles
#============================================================================#
# backup_file()
# syntax: backup_file "file_basename"
# description: move single old dotfile "file_basename" to $OLDDIR if exists
backup_file () {
	local filename=$1
	# backup the original actual file, even it's a symlink
	if [ -f $HOME/.$filename ]
	then
		MSG="  > Backing up original [$filename]..."
		printf "$MSG"
		[[ $print_only_f ]] || mv $HOME/.$filename $OLDDIR
		log_msg "[OK]" "GREEN" "$MSG"
		printf " <\n"
	fi
}

# backup_oldfiles()
# syntax: backup_oldfiles
# description: move old dotfiles to $OLDDIR if any
backup_oldfiles () {
	# Only backup original dotfiles if .dotfiles_old dir doesn't exist
	if [ ! -d $OLDDIR ]
	then
		# set global flag for first-time users
		first_time=1
		echo ">>> Backing up original dotfiles to dotfiles_old/..."
		# There's the problem of .dotfiles_old become a symlink
		# so if .dotfiles_old is a symlink, remove it
		if [ -L $OLDDIR ]; then rm $OLDDIR -f; fi
		# create backup directory if not existing
		(( $print_only_f )) || mkdir -p $OLDDIR > /dev/null

		for f in $DOTFILEDIR/*
		do
			filename=$(basename "$f")
			backup_file $filename
		done
		log_msg "[OK]" "GREEN" ""
		printf " <<<\n"

		repeat "-" $total_width
	fi
}
##############################################################################

##############################################################################
# 03. VIM plugins
#============================================================================#

# install_vundle()
# syntax: install_vundle
# description: download vundle only, use vim PluginInstall to get plugins
install_vundle() {
	MSG=">>> Installing [Vundle] for Vim..."
	printf "$MSG"

	if [ ! -d "$VIMDIR/bundle/Vundle.vim" ]; then
		# if host doesn't have git, check if host user has sudo
		if [ ! -x $(command -v git) ]; then
			if [ -x $(command -v sudo) ]; then
				(( $print_only_f )) || sudo apt-get install -qq -y git
			else
				log_msg "[UNAUTHORIZED]" "RED" "$MSG"; printf " <\n"
				return
			fi
		fi
		# fetch file quietly, suppress error output
		(( $print_only_f )) || \
			git clone \
			https://github.com/gmarik/Vundle.vim.git $VIMDIR/bundle/Vundle.vim \
			2> /dev/null
		log_msg "[Created]" "GREEN" "$MSG"
		printf " <\n"
		#echo "                      [Pathogen] installation completed. <<<"
	else
		#echo "                           [Pathogen] already installed. <<<"
		log_msg "[NOT MODIFIED]" "YELLOW" "$MSG"
		printf " <\n"
	fi
	log_msg "[OK]" "GREEN" ""
printf " <<<\n"
}

# install_pathogen()
# syntax: install_pathogen
# description: download pathongen and use pathogen repo to install vim plugins
install_pathogen() {

	MSG=">>> Installing [Pathogen] for Vim..."
	printf "$MSG"

	(( $print_only_f )) || \
	mkdir -p $VIMDIR/autoload $VIMDIR/bundle

	if [ ! -f "$VIMDIR/autoload/pathogen.vim" ]; then
		(( $print_only_f )) || [ -x $(command -v curl) ] || sudo apt-get install -y curl
		(( $print_only_f )) || curl -Sso $VIMDIR/autoload/pathogen.vim $PATHOGENREPO
		log_msg "[Installation completed.]" "YELLOW" "$MSG"
		printf " <\n"
		#echo "                      [Pathogen] installation completed. <<<"
	else
		#echo "                           [Pathogen] already installed. <<<"
		log_msg "[Already up-to-date]" "GREEN" "$MSG"
		printf " <\n"
	fi
	echo
log_msg "[OK]" "GREEN" ""
printf " <<<\n"

repeat "-" $total_width
}

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


# Patching font
#============================================================================#
# fc-cache -vf ~/.fonts
##############################################################################

##############################################################################
# 04. Creating symlinks
#============================================================================#
# create_symlink()
# syntax: create_symlink "file_basename"
# description: build symlink of dotfile "file_basename" to $HOME dir if any
create_symlink() {
	local filename=$1
	if [[ ! $filename == *.* && -e $DOTFILEDIR/$filename ]]
	then
		MSG="  > Linking file [$filename]..."
		printf "$MSG"
		# remove the old symlinks before linking, deal with the case dotfile_old
		# exists, but symlink is broken
		(( $print_only_f )) || rm $HOME/.$filename -rf
		(( $print_only_f )) || ln -s $DOTFILEDIR/$filename $HOME/.$filename
		log_msg "[OK]" "GREEN" "$MSG"
		printf " <\n"
	else
		MSG="  > Cannot find [$filename]..."
		printf "$MSG"
		log_msg "[NOT FOUND]" "RED" "$MSG"
		printf " <\n"
	fi
}

# install_all()
# syntax: install_all
# description: build up all symlinks of dotfiles to $HOME dir
install_all() {
	echo ">>> Creating symbolic links..."

	# Clean up vim backup files in dotifiles_dir
	# user may change files and leave vim backup files
	# otherwise bootstrap.sh will create symlinks to these hidden files
	#============================================================================#
	shopt -s dotglob # list hidden files
	(( $print_only_f )) || find $DOTFILEDIR -name '*~' -delete 2> /dev/null
	shopt -u dotglob # unlist hidden files

	# looping over all files without extension
	# find . -maxdepth 1 -type f ! -name "*.*"
	for f in $DOTFILEDIR/*
	do
		filename=$(basename "$f")
		if [[ ! $filename == *.* && -e $DOTFILEDIR/$filename ]]; then
			create_symlink $filename
		fi
	done

	log_msg "[OK]" "GREEN" ""
	printf " <<<\n"
}
##############################################################################

##############################################################################
# 05. Deleting symlinks
#============================================================================#
# delete_symlink()
# syntax: delete_symlink "file_basename"
# description: remove symlink of dotfile "file_basename" from $HOME dir if any
delete_symlink() {
	local filename=$1
	# if filename does not have an extension and it actually exists in $HOME
	# then remove the symlink
	if [[ $filename != *.* && -e $HOME/.$filename ]]; then
		MSG="  > Removing dotfile [.$filename]..."
		printf "$MSG"
		# remove the old symlinks before linking, deal with the case dotfile_old
		# exists, but symlink is broken
		(( $print_only_f )) || rm $HOME/.$filename -rf 2> /dev/null
		log_msg "[OK]" "GREEN" "$MSG"
		printf " <\n"
	else
		MSG="  > Cannot find \$HOME/ [.$filename]..."
		printf "$MSG"
		log_msg "[NOT FOUND]" "RED" "$MSG"
		printf " <\n"
	fi
}

# restore_oldfile()
# syntax: restore_oldfile "file_basename"
# description: restore old dotfile "file_basename" from $OLDDIR dir if any
restore_oldfile() {
	local filename=$1
	if [ -f $OLDDIR/.$filename ]; then
		MSG="  > Restoring original file [$filename]..."
		printf "$MSG"
		(( $print_only_f )) || mv $OLDDIR/* $HOME 2> /dev/null
		log_msg "[OK]" "GREEN" "$MSG"
		printf " <\n"
	else
		MSG="  > Cannot find original [.$filename]..."
		printf "$MSG"
		log_msg "[NOT FOUND]" "RED" "$MSG"
		printf " <\n"
	fi
}

# uninstall_all()
# syntax: uninstall_all
# description: remove all symlinks of dotfiles from $HOME dir
uninstall_all() {
	echo ">>> Uninstalling dotfiles..."
	for f in $DOTFILEDIR/*; do
		local filename=$(basename "$f")
		if [[ $filename != *.* && -f $HOME/.$filename ]]; then
			delete_symlink $filename
		fi
	done
	# restore orginal dotfiles
	shopt -s dotglob # list hidden files
	shopt -s nullglob # suppress echo '*' when folder is empty
	for f in $OLDDIR/*; do
		local filename=$(basename "$f")
		restore_oldfile $filename
	done
	shopt -u dotglob # list hidden files
	shopt -u nullglob # suppress echo '*' when folder is empty

	# remove dotfiles_old dir
	(( $print_only_f )) || rm $OLDDIR -rf 2> /dev/null
	log_msg "[OK]" "GREEN" ""
	printf " <<<\n"
}
##############################################################################

##############################################################################
# 06. Back up to github
#============================================================================#
backup_to_github() {

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

	(( $print_only_f )) && exit

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
}
##############################################################################

##############################################################################
# 07. Footer
#============================================================================#
print_footer() {
	repeat "=" $total_width
	if (( $uninstall_f )); then
		center $left_delimiter "   Clean leaving host environment!" $right_delimiter
	else
		center $left_delimiter "Enjoy your new coding environment!" $right_delimiter
	fi
	center $left_delimiter "                         --Maxlufs" $right_delimiter
	repeat "=" $total_width

	if (( $first_time )); then
		echo "original dotfiles can be found in $OLDDIR"
	fi
	if (( $uninstall_f )); then
		echo "remove \$HOME/.dotfiles dir for complete removal"
	fi
	if (( $print_only_f )); then
		center "#####" "${fgyellow}THIS IS DEBUGGING MODE: PRINTING ONLY{}${reset}" "#####"
	fi
}
##############################################################################

##############################################################################
# 99. Main
#============================================================================#
# Declare flags using getopts
#============================================================================#
# getopts only works for 1-character flags
# may use getopt (no POSIX compatible) or hack into a 1-char flag (not
# portable to Mac OS or FreeBSD)

# translate long options to short flags
for arg; do # iterate over all input parameters, no need to write "in $@" here
	delim=""
	case $arg in
		# append -V after args string
		--version ) args="${args}-V "
			;;
		--help ) args="${args}-h "
			;;
		--debug ) args="${args}-p "
			;;
		--pathogen ) args="${args}-t "
			;;
		--vundle ) args="${args}-v "
			;;
		--backup ) args="${args}-b "
			;;
		--uninstall ) args="${args}-u "
			;;
		# put everything else inside quotes, then append after args string
		*) [[ "${arg:0:1}" == "-" ]] || delim="\""
			args="${args}${delim}${arg}${delim} "
	esac
done

# reset the positional parameters to the short options
eval set -- $args

# set up flags, need to parse all flags at least once
version_f=0
help_f=0
print_only_f=0
install_file_f=0
uninstall_file_f=0
pathogen_f=0
vundle_f=0
backup_f=0
uninstall_f=0
file_arr=()
# preceding : in args string sets getopts in silent error mode
# invalid option -> ? (\?) and $OPTARG -> invalid option char
# required argument not found -> : and $OPTARG -> the option char in question
while getopts ":hVptvbuf:d:" opt; do
	case "${opt}" in
		V )
			version_f=1
			;;
		h )
			# print usage then exit, so multiple -h flags won't matter
			help_f=1
			;;
		p )
			print_only_f=1
			;;
		f )
			# install selected file(s)
			install_file_f=1
			file_arr+=("f" "${OPTARG}")
			;;
		d )
			# uninstall selected file(s)
			uninstall_file_f=1
			file_arr+=("d" "${OPTARG}")
			;;
		t )
			pathogen_f=1
			;;
		v )
			vundle_f=1;
			;;
		b )
			backup_f=1
			;;
		u )
			uninstall_f=1
			;;
		\?)
			echo "Usage: invalid option -$OPTARG" >&2
			echo "use -h or --help to show help"
			exit 1
			;;
		:)
			echo "Usage: option -$OPTARG requires an argument." >&2
			echo "use -h or --help to show help"
			exit 1
			;;
	esac
done
unset opt

# getopts has 2 problems:
# 1. invalid options don't stop the processing:
# If you want to stop the script, you have to do it yourself (exit in the right place)
# 2. multiple identical options are possible:
# If you want to disallow these, you have to check manually (e.g. by setting a variable or so)

# set global flag for first-time users
[ ! -d $OLDDIR ] && first_time=1

# script flow
# has -h flag
(( $help_f )) && print_usage && exit 1
# has -V flag
(( $version_f )) && echo "Version: $VERSION" && exit 1
# has --uninstall flag
(( $uninstall_f )) && print_header && uninstall_all && print_footer && exit 1
# has both --pathogen and --vundle flag
if (( $pathogen_f )) && (( $vundle_f )); then
	echo "Usage: select only one between Pathogen or Vundle"
	echo "use -h or --help to show help"
	exit 1
fi

#if [${#file_arr[@]} -eq 0 ] check if array empty. syntax too confusing
if (( $install_file_f )) || (( $uninstall_file_f )); then
	print_header
	#backup_oldfiles
	(( $pathogen_f )) && install_pathogen && repeat "-" $total_width
	# vundle is installed by default
	(( $vundle_f )) && install_vundle && repeat "-" $total_width
	for (( i = 0; i < ${#file_arr[@]}; i+=2 )); do
		flag=${file_arr[$i]}
		filename=${file_arr[$i+1]}
		if [[ "${flag}" == "f" ]]; then
			create_symlink "$filename"
		fi
		if [[ "${flag}" == "d" ]]; then
			delete_symlink "$filename"
			restore_oldfile "$filename"
			continue
		fi
	done
	print_footer
	exit;
fi

# main flow, run without any flags
if (( ! $uninstall_f )); then
	print_header
	backup_oldfiles
	(( $pathogen_f )) && install_pathogen && repeat "-" $total_width
	# vundle is installed by default
	(( ! $pathogen_f )) && install_vundle && repeat "-" $total_width
	install_all
	(( $backup_f )) && repeat "-" $total_width && backup_to_github
	print_footer
fi

# clean variables
unset VERSION
unset DOTFILEDIR
unset OLDDIR
unset VIMDIR
unset BUNDLEDIR

unset version_f
unset help_f
unset print_only_f
unset install_file_f
unset uninstall_file_f
unset pathogen_f
unset vundle_f
unset backup_f
unset uninstall_f

unset terminal_width
unset default_width
unset total_width
unset left_delimiter
unset right_delimiter
unset fgred
unset fggreen
unset fgyellow
unset fgblue
unset fgpurple
unset fgcyan
unset fgwhite
unset bgred
unset bggreen
unset bgyellow
unset bgblue
unset bgpurple
unset bgcyan
unset bgwhite
unset bold
unset underline
unset reset

unset f
unset filename

unset COL
unset MSG
unset COLOR

unset right_start_pos
unset middle_start_pos
unset sum_len
