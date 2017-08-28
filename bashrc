#============================================================================#
    # Filename: .bashrc                                                 #
    # Maintainer: Maximilian Q. Wang <max@linux.com>                    #
    # URL: https://github.com/Maxlufs/dotfiles.git                      #
    # Description: executed by bash(1) for non-login shells.            #
    #===================================================================#
    # Contents:                                                         #
    # 00. Researved ...................                                 #
    # 01. General Settings............. General Vim behavior            #
    # 02. History Settings ............ Vim autocmd events              #
    # 03. Term Settings ............... Colors, fonts, etc.             #
    # 04. Source Files ................ User interface behavior         #
    # 05. Path Settings ............... Text, tab, indentation related  #
#============================================================================#

##############################################################################
# General Bash Behaviours                                                    #
# ========================================================================== #
# If not running interactively, i.e. sub-shells, don't do anything
[ -z "$PS1" ] && return

#set -C
set -o noclobber
##############################################################################

##############################################################################
# Util Functions                                                             #
# ========================================================================== #
__has_command() {
# POSIX
# if command -v <app> >/dev/null; then echo <app> exists; fi
# Problem: <app> may be defined in bash scripts such as aliases, which is
# useless.
# Use -p for force a PATH search (still will include alias)
# Use command -v <app> | grep -v 'alias'
#
# hash
# type
# Problem: type also shows <app> is aliased to <some_alias>
# Use -P to force a PATH search
# if type -P <app> >/dev/null; then echo <app> exists; fi
[ -n "$(type -P $1)" ] && [ -x $(type -P $1) ] # && return 0 || return 1
# NOTE: 0 is true, none 0 is false
}
##############################################################################

##############################################################################
# HISTORY Settings
# ========================================================================== #
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoredups,erasedups
# ignore `clear` and `history` in history, this also disables them when typing
# ctrl+P
HISTIGNORE="clear:history"

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

##############################################################################
# TERM Settings
# ========================================================================== #

# By default, gnome-terminal's $TERM is set by vte, see /usr/share/vte/termcap/xterm
# which uses vte_pty_set_term(). gnome-terminal's source code never used that
# function, therefore it's impossible to change gnome-terminal's $TERM to
# something other than xterm from it's own config.
# The only way to get around it is to use shell to force it
# also use `tset -q` gives $TERM
if [[ $COLORTERM = gnome-* && $TERM =~ xterm ]]
then
	if infocmp gnome-256color >/dev/null 2>&1
	then
		export TERM=gnome-256color
	elif infocmp xterm-256color >/dev/null 2>&1
	then
		export TERM=xterm-256color
	fi
	# This also works well with screenrc's term, whether 8 color or 256 color
fi

# screen and tmux are different, they are terminals within terminals, and can
# only provide functionality within the outer bound.
# outer        inner            inner color
# 8 color      8 color          8 color
# 8 color      256 color        8 color
# 256 color    8 color          256 color (this one is odd)
# 256 color    256 color        256 color

# This one-liner can be used if the remote box doesn't have terminfo of your
# terminal emulator. Check remote /usr/share/terminfo and /lib/terminfo
#infocmp | ssh <HOSTNAME> 'TMP=`mktemp` && cat > $TMP; tic -o .terminfo/ "$TMP" && rm "$TMP"';

if tput setaf 1 &> /dev/null; then
	tput sgr0
	if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
		# solarized colorscheme
		BASE03=$(tput setaf 234)
		BASE02=$(tput setaf 235)
		BASE01=$(tput setaf 240)
		BASE00=$(tput setaf 241)
		BASE0=$(tput setaf 244)
		BASE1=$(tput setaf 245)
		BASE2=$(tput setaf 254)
		BASE3=$(tput setaf 230)
		YELLOW=$(tput setaf 136)
		ORANGE=$(tput setaf 166)
		RED=$(tput setaf 160)
		MAGENTA=$(tput setaf 125)
		VIOLET=$(tput setaf 61)
		BLUE=$(tput setaf 33)
		CYAN=$(tput setaf 37)
		GREEN=$(tput setaf 64)
	else
		# bit 16
		BASE03=$(tput setaf 8)
		BASE02=$(tput setaf 0)
		BASE01=$(tput setaf 10)
		BASE00=$(tput setaf 11)
		BASE0=$(tput setaf 12)
		BASE1=$(tput setaf 14)
		BASE2=$(tput setaf 7)
		BASE3=$(tput setaf 15)
		YELLOW=$(tput setaf 3)
		ORANGE=$(tput setaf 9)
		RED=$(tput setaf 1)
		MAGENTA=$(tput setaf 5)
		VIOLET=$(tput setaf 13)
		BLUE=$(tput setaf 4)
		CYAN=$(tput setaf 6)
		GREEN=$(tput setaf 2)
		# add bit 8 colors : https://github.com/altercation/solarized
	fi
	BOLD=$(tput bold)
	RESET=$(tput sgr0)
else
	# Linux console colors. I don't have the energy
	# to figure out the Solarized values
	MAGENTA="\033[1;31m"
	ORANGE="\033[1;33m"
	GREEN="\033[1;32m"
	PURPLE="\033[1;35m"
	WHITE="\033[1;37m"
	BOLD=""
	RESET="\033[m"
fi

#parse_git_dirty () {
  #[[ $(git status 2> /dev/null | tail -n1) != "nothing to commit
#(working directory clean)" ]] && echo "*"
#}
#parse_git_branch () {
  #git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/*
#\(.*\)/\1$(parse_git_dirty)/"
#}

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
    xterm-256color) color_prompt=yes;;
esac


# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

# Prompt Settings
# ===============
# __update_prompt: calculate the fill_width of the horizontal line
__update_prompt() {
	local pwd=${PWD/#$HOME/\~}

	local prompt_job=''
	local jobcount=$(jobs | wc -l)
	if (( jobcount )); then
		prompt_job="-[$jobcount]"
	fi

	let prompt_width=$( echo \
		"${debian_chroot:+($debian_chroot)}+-[$USER@$HOSTNAME]${prompt_job}---[${pwd}]---" \
		| wc -c )
	local terminal_width=`tput cols`
	local fill_width=$(( $terminal_width - $prompt_width ))
	fill=''
	for i in $(seq $fill_width)
	do
		fill+='─'
	done

	color_prompt_job=''
	if (( jobcount )); then
		color_prompt_job="${VIOLET}-${RESET}[${YELLOW}${jobcount}${RESET}]"
	fi
}

PROMPT_COMMAND=__update_prompt


#__jobscount() {
## jobs -s : stopped -r : running -p : only print processID
  #local stopped=$(jobs -sp | wc -l)
  #local running=$(jobs -rp | wc -l)
  #echo -n "${running}r/${stopped}s"
#}

if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}$VIOLET╭─$RESET[\[\033[01;38;5;70m\]\u@\h\[\033[00m\]]${color_prompt_job}${VIOLET}${fill}───$RESET[\[\033[01;38;5;39m\]\w\[\033[00m\]]$VIOLET──╢$RESET\n\[\033[01;38;5;61m\]╰─\[\033[m\]\$ '
	# cannot use varibale $VIOLET on the second line, prompt gets buggy
else
	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
		;;
	*)
		;;
esac
# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
	#    ;;
	#esac

	# colorize man page
	man() {
		env \
			LESS_TERMCAP_mb=$'\e[01;31m' \
			LESS_TERMCAP_md=$'\e[01;38;5;74m' \
			LESS_TERMCAP_me=$'\e[0m' \
			LESS_TERMCAP_so=$'\e[01;30;48;5;227m' \
			LESS_TERMCAP_se=$'\e[0m' \
			LESS_TERMCAP_us=$'\e[04;38;5;146m' \
			LESS_TERMCAP_ue=$'\e[0m' \
			man "$@"
		#export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # blink
		#export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # bold
		#export LESS_TERMCAP_me=$(tput sgr0)               # reset blink/bold
		#export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # search
		#export LESS_TERMCAP_se=$(tput rmso; tput sgr0)    # reset search
		#export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # start underline
		#export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)    # stop underline
		#export LESS_TERMCAP_mr=$(tput rev)
		#export LESS_TERMCAP_mh=$(tput dim)
		#export LESS_TERMCAP_ZN=$(tput ssubm)
		#export LESS_TERMCAP_ZV=$(tput rsubm)
		#export LESS_TERMCAP_ZO=$(tput ssupm)
		#export LESS_TERMCAP_ZW=$(tput rsupm)
	}

##############################################################################
# Source Files                                                               #
# ========================================================================== #
# Alias definitions

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi
if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
fi
if [ -f ~/.git-flow-completion.bash ]; then
    . ~/.git-flow-completion.bash
fi
# Auto-completion
# already sourced in /etc/bash.bashrc and /etc/profile
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion # well, by default ubuntu sources /usr/share
  fi
fi

# command-not-found
# The command-not-found is a python3 script
# already sourced in /etc/bash.bashrc
# if [ -x /usr/lib/command-not-found ]; then
# 	function command_not_found_handle {
# 	# check because c-n-f could've been removed in the meantime
# 	if [ -x /usr/lib/command-not-found ]; then
# 		/usr/bin/python /usr/lib/command-not-found -- $1
# 		return $? # return exit status from the last command
# 	else
# 		return 127
# 	fi
# }
# fi


##############################################################################
# Path Settings                                                              #
# ========================================================================== #
# Add RVM to PATH for scripting, the following line auto add ~/.rvm/bin though
# PATH=$PATH:$HOME/.rvm/bin
# For Ruby RVM
[[ -s '/home/ubuntu/maxlufs/.rvm/scripts/rvm' ]] && source '/home/ubuntu/maxlufs/.rvm/scripts/rvm'

PATH="$HOME/.cabal/bin:$PATH"

# include user's private bin dir if exists
if [ -d ~/bin ]; then
	PATH=~/bin:"${PATH}"
fi

export FZF_DEFAULT_OPTS="--sort 20000"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
