#!/bin/sh

source ./common.inc

remotes=$(git remote)
if [ -z "$remotes" ]; then
	echo "No remotes found."
	exit 1;
fi;

typeset -i i lineCount

let i=1
lineCount=$(echo "$remotes" | wc -l);

while ((i<=lineCount)); do
	r=$(echo "$remotes" | cut -f $i -d $'\n')
	git fetch $r
	git push -u $r master
    let i++;
done

