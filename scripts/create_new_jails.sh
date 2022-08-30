#!/bin/sh

usage(){
	cat <<EOF
Creates new poudriere jails for both i386 and amd64
create_new_jails.sh <release_name> <directory>

e.g. 
create_new_jails.sh 14.0-CURRENT snapshots
create_new_jails.sh 13.1-RELEASE releases
EOF
}

if [ "$#" -lt 2 ]; then
	usage
	exit 1
fi

RELEASE="${1}"
JAIL_RELEASE_NAME=$(echo ${RELEASE} | sed 's/\./_/g')
DIR="${2}"

for ARCH in amd64 i386; do
	poudriere jail -c \
			-v ${RELEASE} \
			-a ${ARCH} \
			-p local \
			-m url=ftp://ftp.freebsd.org/pub/FreeBSD/${DIR}/${ARCH}/${ARCH}/${RELEASE} \
			-j ${JAIL_RELEASE_NAME}__${ARCH}
done

#poudriere jail -c -v ${RELEASE} -a amd64 -p local -m url=ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/amd64/amd64/${RELEASE} -j ${RELEASE}__amd64
#poudriere jail -c -v ${RELEASE} -a i386 -p local -m url=ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/${RELEASE} -j ${RELEASE}__i386
