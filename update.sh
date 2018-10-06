#!/bin/sh

if ! echo $(uname) | grep -i BSD > /dev/null; then
	# If we aren't on a *BSD then we'll use Bash to figure out where we are
	DIR=$( bash -c 'cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd' ) 
	# FROM http://stackoverflow.com/questions/59895/
	#		can-a-bash-script-tell-what-directory-its-stored-in
else
	DIR=$(dirname $(readlink -f "$0"))
fi

git -C $DIR pull > /dev/null 2>&1
git -C $DIR submodule init > /dev/null 2>&1
git -C $DIR submodule update > /dev/null 2>&1
