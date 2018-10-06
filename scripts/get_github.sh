#!/bin/sh

github () {
if [ -d ".git" ]; then
	COMMIT=$(git show | grep "^commit " | sed 's/commit \(.......\).*/\1/')
	SITE=$(pwd | awk -F/ '{print $5}')
	ACCOUNT=$(pwd | awk -F/ '{print $6}')
	REPO=$(pwd | awk -F/ '{print $7}')
	REPOUNDER=$(pwd | awk -F/ '{print $7}'| sed 's/-/_/g')
	echo "$ACCOUNT:$REPO:$COMMIT:$REPOUNDER/src/$SITE/$ACCOUNT/$REPO"
	return
fi
for EACH in *; do
	if [ -d $EACH ]; then
		cd $EACH
		github
		cd ..
		fi
	done
}
cd $1
github
