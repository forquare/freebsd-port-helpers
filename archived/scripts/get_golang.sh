#!/bin/sh

golang () {
if [ -d ".git" ]; then
	COMMIT=$(git show | grep "^commit " | sed 's/commit \(.......\).*/\1/')
	SITE=$(pwd | awk -F/ '{print $5}')
	ACCOUNT="golang"
	REPO=$(pwd | awk -F/ '{print $7}')
    REPOUNDER=$(pwd | awk -F/ '{print $7}'| sed 's/-/_/g')
	echo "$ACCOUNT:$REPO:$COMMIT:$REPOUNDER/src/$SITE/x/$REPO"
	return
fi
for EACH in *; do
	if [ -d $EACH ]; then
		cd $EACH
		golang
		cd ..
		fi
	done
}
cd $1
golang
