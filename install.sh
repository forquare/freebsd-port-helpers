#!/bin/sh

if ! echo $(uname) | grep -i BSD > /dev/null; then
	# If we aren't on a *BSD then we'll use Bash to figure out where we are
	DIR=$( bash -c 'cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd' ) 
	# FROM http://stackoverflow.com/questions/59895/
	#		can-a-bash-script-tell-what-directory-its-stored-in
else
	DIR=$(dirname $(readlink -f "$0"))
fi

for E in scripts; do
	if [ ! -e $HOME/$E ]; then
		ln -sf $DIR/$E $HOME/$E
	fi
done

if [ ! -e $HOME/bin ]; then
	mkdir $HOME/bin
fi

git -C $DIR submodule update --recursive --remote > /dev/null 2>&1
