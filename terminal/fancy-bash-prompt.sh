#!/bin/bash

##	+-----------------------------------+-----------------------------------+
##	|                                                                       |
##	| Copyright (c) 2018-2019, Andres Gongora <mail@andresgongora.com>.     |
##	|                                                                       |
##	| This program is free software: you can redistribute it and/or modify  |
##	| it under the terms of the GNU General Public License as published by  |
##	| the Free Software Foundation, either version 3 of the License, or     |
##	| (at your option) any later version.                                   |
##	|                                                                       |
##	| This program is distributed in the hope that it will be useful,       |
##	| but WITHOUT ANY WARRANTY; without even the implied warranty of        |
##	| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         |
##	| GNU General Public License for more details.                          |
##	|                                                                       |
##	| You should have received a copy of the GNU General Public License     |
##	| along with this program. If not, see <http://www.gnu.org/licenses/>.  |
##	|                                                                       |
##	+-----------------------------------------------------------------------+


##
##	DESCRIPTION
##
##	This script updates your "PS1" environment variable to display colors.
##	Additionally, it also shortens the name of your current path to a maximum
##	25 characters, which is quite useful when working in deeply nested folders.
##
##
##
##
##	FUNCTIONS
##
##	* git_branch()
##	  This function takes your current working branch of git
##
##	* bash_prompt_command()
##	  This function takes your current working directory and stores a shortened
##	  version in the variable "NEW_PWD".
##
##	* bash_prompt()
##	  This function colorizes the bash promt. The exact color scheme can be
##	  configured here. The structure of the function is as follows:
##		1. A. Definition of available colors for 16 bits.
##		1. B. Definition of some colors for 256 bits (add your own).
##		2. Configuration >> EDIT YOUR PROMT HERE<<.
##		4. Generation of color codes.
##		5. Generation of window title (some terminal expect the first
##		   part of $PS1 to be the window title)
##		6. Formating of the bash promt ($PS1).
##
##	* Main script body:
##	  It calls the adequate helper functions to colorize your promt and sets
##	  a hook to regenerate your working directory "NEW_PWD" when you change it.
##
##
##
##
##
##	REFFERENCES
##
##	* http://tldp.org/HOWTO/Bash-Prompt-HOWTO/index.html
##
##




##==============================================================================
##	FUNCTIONS
##==============================================================================


##------------------------------------------------------------------------------
##
bash_prompt_command()
{
	## LOAD EXTERNAL DEPENENCIES
	## Only if the functions are not available
	## If not, search in `common` folder
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	if [ "$(type -t shortenPath)" != 'function' ];
	then
		source "$dir/../common/shorten_path.sh"
	fi



	## SHORTEN AND STORE PWD IN GLOBAL VARIABLE
	SHORT_PWD=$(shortenPath $PWD 20)
}






##------------------------------------------------------------------------------
##	getGitBranch
##	Returns current git branch for current directory, if and only if,
##	the current directory is part of a git repository, and git is installed.
##	Returns an empty string otherwise.
##  
getGitBranch()
{
	if ( which git > /dev/null 2>&1 ); then
		git branch 2> /dev/null | sed -n '/^[^*]/d;s/*\s*\(.*\)/\1/p'
	else
		echo ""
	fi
}






##------------------------------------------------------------------------------
##
bash_prompt()
{
	## INCLUDE EXTERNAL DEPENDENCIES
	## Only if the functions are not available
	## If not, search in `common` folder
	local dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	if [ "$(type -t loadConfigFile)" != 'function' ];
	then
		source "$dir/../common/load_config.sh"
	fi

	if [ "$(type -t getFormatCode)" != 'function' ];
	then
		source "$dir/../common/color.sh"
	fi



	## DEFAULT CONFIGURATION
	## WARNING! Do not edit directly, use configuration files instead
	local font_color_user="white"
	local background_user="blue"
	local texteffect_user="bold"

	local font_color_host="white"
	local background_host="light-blue"
	local texteffect_host="bold"

	local font_color_pwd="dark-gray"
	local background_pwd="white"
	local texteffect_pwd="bold"

	local font_color_git="white"
	local background_git="dark-gray"
	local texteffect_git="bold"

	local font_color_input="cyan"
	local background_input="none"
	local texteffect_input="bold"

	local separator_char=$'\uE0B0'

	local enable_vertical_padding=true
	local show_user=true
	local show_host=true
	local show_pwd=true
	local show_git=true



	## LOAD USER CONFIGURATION
	local user_config_file="$HOME/.config/scripts/fancy-bash-prompt.config"
	local sys_config_file="/etc/andresgongora/scripts/fancy-bash-prompt.config"
	if   [ -f $user_config_file ]; then
		loadConfigFile $user_config_file
	elif [ -f $sys_config_file ]; then
		loadConfigFile $sys_config_file
	fi



	## GENERATE COLOR FORMATING SEQUENCES
	## The sequences will confuse the bash promt. To tell the terminal that they are non-printint
	## characters, we must surround them by \[ and \]
	local no_color="\[$(getFormatCode -e reset)\]"
	local ps1_user_format="\[$(getFormatCode        -c $font_color_user  -b $background_user  -e $texteffect_user)\]"
	local ps1_host_format="\[$(getFormatCode        -c $font_color_host  -b $background_host  -e $texteffect_host)\]"
	local ps1_pwd_format="\[$(getFormatCode         -c $font_color_pwd   -b $background_pwd   -e $texteffect_pwd)\]"
	local ps1_git_format="\[$(getFormatCode         -c $font_color_git   -b $background_git   -e $texteffect_git)\]"
	local ps1_input_format="\[$(getFormatCode       -c $font_color_input -b $background_input -e $texteffect_input)\]"
	local separator_1_format="\[$(getFormatCode     -c $background_user  -b $background_host)\]"
	local separator_2_format="\[$(getFormatCode     -c $background_host  -b $background_pwd)\]"
	local separator_3_format="\[$(getFormatCode     -c $background_pwd)\]"
	local separator_3_git_format="\[$(getFormatCode -c $background_pwd   -b $background_git)\]"
	local separator_4_git_format="\[$(getFormatCode -c $background_git)\]"



	## GENERATE USER/HOST/PWD TEXT
	local ps1_user="${ps1_user_format} \u "
	local ps1_host="${ps1_host_format} \h "
	local ps1_pwd="${ps1_pwd_format} \${SHORT_PWD} "
	local ps1_git="${ps1_git_format} \$(getGitBranch) "
	local ps1_input="${ps1_input_format} "



	## GENERATE SEPARATORS
	## The exact number and color of the separators depends on
	## whenther the current directory is part of a git repo
	if [ -z "$(getGitBranch)" ]; then 
		echo "empty"
		local separator_1="${separator_1_format}${separator_char}"
		local separator_2="${separator_2_format}${separator_char}"
		local separator_3="${separator_3_format}${separator_char}"
	else
		echo "not empty"
		local separator_1="${separator_1_format}${separator_char}"
		local separator_2="${separator_2_format}${separator_char}"
		local separator_3="${separator_3_git_format}${separator_char}"
		local separator_4="${separator_4_git_format}${separator_char}"
	fi



	## Add extra new line on top of prompt
	if $enable_vertical_padding; then
		local vertical_padding="\n"
	else
		local vertical_padding=""
	fi



	## WINDOW TITLE
	## Prevent messed up terminal-window titles
	## Must be set in PS1
	case $TERM in
	xterm*|rxvt*)
		local titlebar='\[\033]0;\u:${NEW_PWD}\007\]'
		;;
	*)
		local titlebar=""
		;;
	esac



	## BASH PROMT - Generate promt and remove format from the rest
	if [ -z "$(getGitBranch)" ];
	then
	 	PS1="$titlebar${vertical_padding}${ps1_user}${separator_1}${ps1_host}${separator_2}${ps1_pwd}${separator_3}${ps1_input}"	
	else
		PS1="$titlebar${vertical_padding}${ps1_user}${separator_1}${ps1_host}${separator_2}${ps1_pwd}${separator_3}${ps1_git}${separator_4}${ps1_input}"
	fi



	## For terminal line coloring, leaving the rest standard
	none="$(tput sgr0)"
	trap 'echo -ne "${none}"' DEBUG
}






##==============================================================================
##	MAIN
##==============================================================================

##	Bash provides an environment variable called PROMPT_COMMAND.
##	The contents of this variable are executed as a regular Bash command
##	just before Bash displays a prompt.
##	We want it to call our own command to truncate PWD and store it in NEW_PWD
PROMPT_COMMAND=bash_prompt_command

##	Call bash_promnt only once, then unset it (not needed any more)
##	It will set $PS1 with colors and relative to $NEW_PWD,
##	which gets updated by $PROMT_COMMAND on behalf of the terminal
bash_prompt
unset bash_prompt



### EOF ###
