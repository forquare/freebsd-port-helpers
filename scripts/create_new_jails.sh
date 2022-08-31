#!/bin/sh

usage(){
	cat <<EOF
Creates new poudriere jails for both i386 and amd64
create_new_jails.sh <release_name> [directory]

e.g. 
create_new_jails.sh 15.0-CURRENT 
create_new_jails.sh 14.0-CURRENT snapshots
create_new_jails.sh 13.1-RELEASE releases

If [directoty] is missing then the script will guess:
"-RELEASE" will be retrieved from 'releases'
Othrwise it will be retrieved from 'snapshots'
EOF
}

if [ "$#" -lt 1 ]; then
	usage
	exit 1
fi

RELEASE="${1}"
JAIL_RELEASE_NAME=$(echo ${RELEASE} | sed 's/\./_/g')

if [ "$#" -eq 2 ]; then
	DIR="${2}"
	if [ "${DIR}" = "releases" ]; then
		METHOD="ftp"
	else
		METHOD="url=ftp://ftp.freebsd.org/pub/FreeBSD/${DIR}/__ARCH__/__ARCH__/${RELEASE}"
	fi
else
	if echo ${RELEASE} | grep -qi 'RELEASE$'; then
		METHOD="ftp"
	else
		DIR='snapshots'
		METHOD="url=ftp://ftp.freebsd.org/pub/FreeBSD/${DIR}/__ARCH__/__ARCH__/${RELEASE}"
	fi
fi

for ARCH in amd64 i386; do
	METHOD=$(echo ${METHOD} | sed "s/__ARCH__/${ARCH}/g")
	poudriere jail -c \
			-v ${RELEASE} \
			-a ${ARCH} \
			-p local \
			-m ${METHOD} \
			-j ${JAIL_RELEASE_NAME}__${ARCH}
done

#poudriere jail -c -v ${RELEASE} -a amd64 -p local -m url=ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/amd64/amd64/${RELEASE} -j ${RELEASE}__amd64
#poudriere jail -c -v ${RELEASE} -a i386 -p local -m url=ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/${RELEASE} -j ${RELEASE}__i386
