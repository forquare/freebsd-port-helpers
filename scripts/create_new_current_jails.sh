#!/bin/sh

# Below should (untested!) create two non-RELEASE jails that require special URLs


if [ "$#" -gt 0 ]; then
	RELEASE="${1}"
	JAIL_RELEASE_NAME=$(echo ${RELEASE} | sed 's/\./_/g')
else
	echo "Need a release!"
	exit 1
fi

for ARCH in amd64 i386; do
	poudriere jail -c \
			-v ${RELEASE} \
			-a ${ARCH} \
			-p local \
			-m url=ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/${ARCH}/${ARCH}/${RELEASE} \
			-j ${JAIL_RELEASE_NAME}__${ARCH}
done
#poudriere jail -c -v ${RELEASE} -a amd64 -p local -m url=ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/amd64/amd64/${RELEASE} -j ${RELEASE}__amd64
#poudriere jail -c -v ${RELEASE} -a i386 -p local -m url=ftp://ftp.freebsd.org/pub/FreeBSD/snapshots/i386/i386/${RELEASE} -j ${RELEASE}__i386
