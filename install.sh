#!/bin/sh

# Read a new string value or accept a default value
# $1 is the file name
# $2 is the source directory
# $3 is the destination directory
# Returns 1 copy was successful, or 0 if not successful
function InstallSetupFile () {
	local srcPath
	local destPath;
	
	srcPath=$(echo $2 | sed 's|/\+$||g');
	srcPath="$srcPath/$1";
	
	if [[ ! -f $srcPath ]]; then
		echo "Source file not found at: $srcPath";
		return 0;
	fi
	
	destPath=$(echo $3 | sed 's|/\+$||g');
	destPath="$destPath/$1";
	
	cp $srcPath $destPath
	
	if [ $? -ne 0 ]; then
		echo "Unexpected error while copying to: $destPath"
		return 0;
	fi
	
	if [[ ! -f $srcPath ]]; then
		echo "Unable to copy item to: $srcPath";
		return 0;
	fi
	
	return 1
}

gitPath = $(which git)

if [[ ! -f "$gitPath" ]]; then
	echo "It does not appear that git is installed.";
fi

destPath=~/bin
if [[ ! -a "$destPath" ]]; then
	echo "mkdir $destPath"
	mkdir $destPath
	if [[ ! -a "$destPath" ]]; then
		echo "Folder named $destPath could not be created.";
		exit 1;
	fi
fi

srcDir=$(pwd)

success=1;
InstallSetupFile "common.inc" "$srcDir" "$destPath"
if [ $? -eq 0 ]; then success=0; fi
InstallSetupFile "clone_github_repo.sh" "$srcDir" "$destPath"
if [ $? -eq 0 ]; then success=0; fi
InstallSetupFile "sync_all.sh" "$srcDir" "$destPath"
if [ $? -eq 0 ]; then success=0; fi

if [ $success -eq 0 ]; then
	echo "Finished with errors";
else
	echo "Finished";
fi