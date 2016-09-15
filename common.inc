#!/bin/sh

shopt -s extglob nocaseglob nocasematch

# Default remote username if one is not provided.
export defaultUserName=""

# Remote GIT server host name
export remoteHostName="github.com"

# Protocol to use for remote URL
export protocol="https"

# true to put user name at root of remote path, otherwise, user name is prepended to the host name.
export userNameAtPathRoot=true

export REPOSITORY_NAME_NOT_PROVIDED=100
export NO_DEFAULT_USERNAME=101

# Builds remote URL according to settings above
# $1 is the remote repository name (without the .git extension)
# $2 is variable name to receive the result
#    If this argument is empty or not provided, then the url will be echoed.
# $3 is the optional remote user name.
#    If this argument is empty or not provided, then defaultUserName is used to determine the remot user name.
# if $2 is defined and not empty, Returns true if the url was successfully created or false upon failure. Otherwise, the url is returned.
# if $2 is defined and not empty, any errors will be echoed, otherwise, an exception will be thrown.
function GetRemoteUrl () {
	local userName
	local url;
	
	if [ -z "$1" ]; then
		[ -z "$2" ] && throw REPOSITORY_NAME_NOT_PROVIDED "Remote repository name not provided"
		echo "Remote repository name not provided"
		return ""
	fi
	userName="$3"
	if [ -z "$userName" ]; then
		if [ -z "$defaultUserName" ]; then
			[ -z "$2" ] && throw NO_DEFAULT_USERNAME "User name not provided and default user name not defined"
			echo "User name not provided and default user name not defined"
			return ""
		fi
		userName="$defaultUserName"
	fi

	if [ $userNameAtPathRoot -eq true ]; then
		url="$protocol://$remoteHostName/$userName/$1.git"
	else
		url="$protocol://$userName@$remoteHostName/$1.git"
	fi
	if [ -z "$2" ]; then
		echo $url;
	else
		eval $2=\$url;
	fi
}

# Gets Prompts user to answer yes or no to a prompt
# $1 is the optional custom prompt
#    This will automatically append an appropriate variation " [y/n]" to the prompt
# $2 is the optional default value that is used if the user enters a blank line. If used, this should be 1, 0, y or n.
#    If this argument is empty or not provided, then the user must answer a yes or no before proceeding.
# Returns 1 if the user answered "yes" or 0 if the user answered "no"
function GetYesOrNo () {
	local prompt
	local defaultResponse;
	local reply
	
	prompt=$'\n'"$1 "
	
	case "$2" in
		N*|n*|+(0))
			prompt="$prompt[y/N] "
			defaultResponse=0
			;;
		Y*|y*|+([[:digit:]]))
			prompt="$prompt[Y/n] "
			defaultResponse=1
			;;
		*)
			prompt="$prompt[y/n] "
			;;
	esac;
	
    while true; do
		read -p "$prompt" reply
		case "$reply" in
			N*|n*|+(0)) return 0 ;;
			Y*|y*|+([[:digit:]])) return 1 ;;
			*)
				if [ -z "$reply" ]; then
					if [ -z "$defaultResponse" ]; then
						echo "Invalid input"
					else
						return $defaultResponse
					fi
				else
					echo "Invalid input";
				fi
			;;
		esac
	done
}

# Read a new string value or accept a default value
# $1 is variable name to receive the result
#    If this argument is empty or not provided, then the response will be echoed.
# $2 is the optional custom prompt
#    This will automatically prepend the default value to the prompt.
#    If this argument is empty or not provided, then a default prompt of "Enter value:" is used
# $3 is the optional default value that is used if the user enters a blank line.
#    If an empty string is used for this parameter, then the user will effectively be able to respond with an empty string.
# Returns 1 if input was received or 0 if the user provided no input and no default value was provided.
# This does not accept any slash characters in the user's response
function ReadNzLine () {
	local prompt
	local reply
	
	if [ -z "$2" ]; then
		prompt="Enter value: ";
	else
		prompt="$2 ";
	fi
	if [ ! -z "$3" ]; then
		prompt="(Enter blank line to accept default: $3)"$'\n'"$prompt ";
	fi
	
    while true; do
		read -p $'\n'"$prompt" reply
		if [ -z "$reply" ]; then
			if [ $# -lt 3 ]; then
				return 0;
			else
				eval $1=\$3
				return 1;
			fi;
		fi
		
		if [[ $reply = *([[:space:]]) ]]; then
			echo "Invalid input: Name must contain at least one non-space character.";
		elif [[ $reply = *([!/]) ]]; then
			if [ -z "$1" ]; then
				echo $reply;
			else
				eval $1=\$reply;
			fi
			return 1;
		else
			echo "Invalid input: Slashes not supported.";
		fi;
	done
}

# Read a new string value, accept a default value or prompt user whether to exit
# $1 is variable name to receive the result
#    If this argument is empty or not provided, then the response will be echoed.
# $2 is the optional custom prompt
#    This will automatically prepend the default value to the prompt.
#    If this argument is empty or not provided, then a default prompt of "Enter value:" is used
# $3 is the optional default value that is used if the user enters a blank line.
#    If this argument is empty or not provided, then the user will be prompted whether they want to exit.
# Returns 1 if input was received or 0 if the user provided no input and the user opted to exit.
# This does not accept any slash characters in the user's response
function ReadNzLineOrExit () {
	while true; do
		if [ -z "$3" ]; then
			# reply=$(ReadNzLine "" "$2");
			ReadNzLine "$1" "$2";
		else
			# reply=$(ReadNzLine "" "$2" "$3");
			ReadNzLine "$1" "$2" "$3";
		fi
		if [ $? -ne 0 ]; then break; fi;
		GetYesOrNo "Exit?" 0
		if [ $? -ne 0 ]; then return 0; fi;
	done
	
	return 1;
}
