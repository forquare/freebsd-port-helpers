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

if ! fetch -q -o "${TAR}" "${URL}"; then
	usage 'Error downloading file' 4
fi

TMPDIR=$(mktemp -d /tmp/$0.XXXXX)

tar xf "${TAR}" -C ${TMPDIR}

GOMOD=$(cd ${TMPDIR}/*/ && go mod graph | awk '{print $2}' | sort | uniq)
rm -rf ${TMPDIR} "${TAR}"

for E in $(echo "$GOMOD"); do
	url=$(echo ${E} | awk -F@ '{print $1}')
	revision=$(echo ${E} | awk -F@ '{print $2}')
	
	# Try to weed out duplicate repos
	latest=$(echo "$GOMOD" | grep "${url}" | awk -F@ '{print $2}' | sort | tail -1)
	if [ "${latest}" != ${revision} ]; then
		continue
	fi
	
	site=$(echo ${url} | awk -F/ '{print $1}')
	account=$(echo ${url} | awk -F/ '{print $2}')
	repo=''
	tag='XXXXX'
	
	if echo "${site}" | grep '^golang.org' > /dev/null; then
		account='golang'
	elif echo "${site}" | grep '^gopkg.in' > /dev/null; then
		if echo "${account}" | grep '\.v[0-9]*$' > /dev/null; then
			repo=$(basename "${account}" | sed 's/\.v[0-9]*$//')
			account="go-${repo}"
		else
			echo "-- MANUALLY DO ${E} --"
		fi
	fi
	
	if [ -z ${repo} ]; then
		repo=$(echo ${url} | awk -F/ '{print $3}')
	fi
	
	underscore_repo=$(echo ${repo} | sed 's/-/_/g')
	
	if echo ${revision} | grep '^[vV][[:digit:].]*$' > /dev/null; then
		# We've got a standalone version, e.g. v1.2.3
		tag="${revision}"
	elif echo ${revision} | grep '[vV][[:digit:].]*-[[:digit:]]\{14\}-[[:alnum:]]\{12\}' > /dev/null; then
		# We've got a tag that looks like: v0.0.0-20180624165032-615eaa47ef79
		tag=$(echo ${revision} | awk -F- '$3 > 0 {print substr($3,1,7)}')
	elif echo ${revision} | grep '+incompatible' > /dev/null; then
		# We've got something like v2.3.5+incompatible
		tag=$(echo ${revision} | awk -F+ '{print $1}')
	fi
	
	#echo "${account}:${repo}:${tag}:${underscore_repo}/src/${url}"
	printf '\t\t%s:%s:%s:%s/src/%s\n' "${account}" "${repo}" "${tag}" "${underscore_repo}" "${url}"
	
done | sort | uniq | awk 'NR>1{print prev " \\"} {prev=$0} END{ if (NR) print prev (prev == "" ? "" : "") }'

