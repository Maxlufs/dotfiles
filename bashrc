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

set -o noclobber
#set -C
##############################################################################

##############################################################################
# HISTORY Settings
# ========================================================================== #
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
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

# PS1 Settings
# ============
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
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

export TERM=xterm-256color


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

# Auto-completion
# already sourced in /etc/bash.bashrc and /etc/profile
# if ! shopt -oq posix; then
#   if [ -f /usr/share/bash-completion/bash_completion ]; then
#     . /usr/share/bash-completion/bash_completion
#   elif [ -f /etc/bash_completion ]; then
#     . /etc/bash_completion # well, by default ubuntu sources /usr/share
#   fi
# fi

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

