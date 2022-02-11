branchName="main"
upstreamName="upstream"
originName="origin"

git pull --tags "$originName" "$branchName"
git fetch "$upstreamName"
git merge "$upstreamName/$branchName"
if [ $? -ne 0 ]; then exit 3; fi;
git push "$originName" "$branchName:$branchName"