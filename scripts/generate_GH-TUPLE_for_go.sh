#!/bin/sh

usage(){
        echo "
(!)$1

$0 <url_to_repo_tar_file>
    Fetch tar file, and parse modules required for Makefile
"
exit $2
}


if [ $# -lt 1 ]; then
        usage 'Not enough arguments' 1
fi

if [ $# -gt 1 ]; then
        usage 'Too many arguments' 2
fi

if [ "$1" == '-h' ]; then
        usage 'Usage:' 0
fi

if ! echo "$1" | grep -i '^http' > /dev/null; then
        usage "Doesn't look like a URL to a repo to a tar file to me (needs http?)" 3
fi

URL="$1"
TAR=/tmp/$(basename "${URL}")

if ! curl -sL -o "${TAR}" "${URL}"; then
        usage 'Error downloading file' 4
fi

TMPDIR=$(mktemp -d /tmp/$(basename $0).XXXXX)

tar xf "${TAR}" -C ${TMPDIR}

cd ${TMPDIR}/*
go mod vendor
modules2tuple vendor/modules.txt
