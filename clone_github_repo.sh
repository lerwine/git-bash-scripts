#!/bin/sh

source ./common.inc

userName="$defaultUserName"
repoName=""
branchName=""
url=""
noPrompt=0;
showHelp=0;

errorOpt=0
currentOpt=1
while getopts ":u:r:b:nh?" flag
do
	if [ $errorOpt -ne $currentOpt ]; then
		case "$flag" in
			u) userName=$OPTARG ;;
			r) repoName=$OPTARG ;;
			b) branchName=$OPTARG ;;
			n) noPrompt=1 ;;
			h) showHelp=1 ;;
			\?)
				errorOpt=$currentOpt
				eval a=\${$currentOpt}
				case "$a" in
					\-\-help|\-\?) showHelp=1 ;;
					?*)
						echo "Invalid argument: $a"
						showHelp=1
					;;
				esac
		esac
	fi
	currentOpt=$OPTIND
done

if [ $showHelp -eq 1 ]; then
	echo "$0 [options]"
	echo "Clones a repo from GitHub, where [options] are:"
	echo "    -u user_name: Specify user name in GitHub"
	echo "    -r repo_name: Specify repository name in GitHub"
	echo "    -b branch_name: Specify branch name in repository name in GitHub"
	echo "    -n: Do not prompt for missing values (user name, repo, branch). If branch is not provided then it will be assumed that HEAD should be cloned"
	echo "    -?"
	echo "    -h"
	echo "    --help: Show Help"
	exit 1;
fi

if [ -z "$userName" ]; then
	if [ $noPrompt -ne 0 ]; then
		echo "User name not provided";
		exit 2;
	fi
	ReadNzLineOrExit userName 'Enter user name:'
	if [ $? -eq 0 ]; then exit 3; fi;
fi

if [ -z "$repoName" ]; then
	if [ $noPrompt -ne 0 ]; then
		echo "User name not provided";
		exit 2;
	fi
	ReadNzLineOrExit repoName 'Enter repository name:'
	if [ $? -eq 0 ]; then exit 3; fi;
fi

if [ -z "$branchName" ]; then
	if [ $noPrompt -eq 0 ]; then
		ReadNzLine branchName 'Enter branch name (enter blank for none (HEAD)):' ''
		if [ $? -eq 0 ]; then exit 3; fi
	fi
fi

if [ -z "$branchName" ]; then
	declare -x dirName="$userName-$repoName";
else
	declare -x dirName="$userName-$repoName-$branchName";
fi

if [[ -a "$dirName" ]]; then
	echo "Folder named $dirName already exists. Try sync_github_repo.sh instead.";
	exit 4;
fi

echo "mkdir $dirName"
mkdir $dirName

if [[ ! -a "$dirName" ]]; then
	echo "Folder named $dirName could not be created.";
	exit 5;
fi

GetRemoteUrl $repoName url $userName
[ $? -eq false ] && exit 5

if [ -z $branchName ]; then
	echo "git clone -n --recursive \"$url\" \"$dirName\""
	git clone "$url" "$dirName"
else
	echo "git clone -n -b --recursive \"$branchName\" \"$url\" \"$dirName\""
	git clone -b "$branchName" "$url" "$dirName"
fi

exit 0;
