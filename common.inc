#!/bin/sh

shopt -s extglob nocaseglob nocasematch

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
