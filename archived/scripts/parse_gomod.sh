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

TMPDIR=$(mktemp -d /tmp/$(basename $0).XXXXX)

tar xf "${TAR}" -C ${TMPDIR}

PROJECT_REPO=$(dirname $(dirname $(echo "${URL}" | sed 's|.*//||')))
GOMOD=$(cd ${TMPDIR}/*/ && go list -m all 2>/dev/null | grep -v "${PROJECT_REPO}")
rm -rf ${TMPDIR} "${TAR}"

IFS='
'
for E in $(echo "$GOMOD"); do
	url=$(echo ${E} | awk '{print $1}')
	revision=$(echo ${E} | awk '{print $2}')
	
	# Try to do replacements
	if echo ${E} | grep " => " > /dev/null; then
		url=$(echo ${E} | awk '{print $4}')
		revision=$(echo ${E} | awk '{print $5}')
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
		elif echo "${url}" | grep -q '\.v[0-9]*$'; then
			repo=$(echo "${url}" | awk -F/ '{print $3}' | sed 's/\.v[0-9]*$//')
			account=$(echo ${url} | awk -F/ '{print $2}')
		else
			echo "-- MANUALLY DO ${E} --"
		fi
	elif echo "${site}" | grep -q 'bazil.org'; then
		repo="${account}"
		account='bazil'
	elif echo "${site}" | grep -q 'contrib.go.opencensus.io'; then
		account='census-ecosystem'
		_repo=$(basename "${url}")
		_account=$(echo ${url} | awk -F/ '{print $2}')
		repo="opencensus-go-${_account}-${_repo}"
	elif echo "${site}" | grep -q 'go.etcd.io'; then
		repo="${account}"
		account='etcd-io'
	elif echo "${site}" | grep -q 'go.uber.org'; then
		repo="${account}"
		account='uber-go'
	elif echo "${site}" | grep -q 'pack.ag'; then
		repo="${account}"
		account='vcabbage'
	elif echo "${site}" | grep -q 'go.mongodb.org'; then
		if echo "${account}" | grep -q 'mongo-driver'; then
			repo='mongo-go-driver'
			account='mongodb'
		else
			echo "-- MANUALLY DO ${E} --"
		fi
	elif echo "${site}" | grep -q 'honnef.co'; then
		repo=$(echo ${url} | awk -F/ '{print $2 "-" $3}')
		account='dominikh'
	elif echo "${site}" | grep -q 'gocloud.dev'; then
		repo='go-cloud'
		account='google'
	elif echo "${site}" | grep '^github.com' > /dev/null; then
		# Make sure Github URLs only have github.com/account/repo
		url=$(echo ${url} | awk -F/ '{print $1 "/" $2 "/" $3}')
	fi
	
	# If we haven't used some special repo, use the 3rd field in URL
	if [ -z ${repo} ]; then
		repo=$(echo ${url} | awk -F/ '{print $3}')
	fi
	
	# If we still don't have a repo, skip
	if [ -z ${repo} ]; then
		continue
	fi
	
	group=$(echo ${repo} | sed 's/-/_/g')
	# If there is another repo with the same name, give this one a different
	# group
	if echo "${GOMOD}" | grep -vi "${E}" | grep -i "${repo}" > /dev/null; then
		group="${account}_${group}"
	fi
	
	if echo ${revision} | grep '^[vV][[:digit:].]*$' > /dev/null; then
		# We've got a standalone version, e.g. v1.2.3
		tag="${revision}"
	elif echo ${revision} | grep '[vV][[:digit:].]*-[[:digit:]]\.[[:digit:]]\{14\}-[[:alnum:]]\{12\}' > /dev/null; then
		# We've got a tag that looks like: v1.0.1-0.20181028145347-94f6ae3ed3bc
		tag=$(echo ${revision} | awk -F- '$3 > 0 {print substr($3,1,7)}')
	elif echo ${revision} | grep '[vV][[:digit:].]*-[[:digit:]]\{14\}-[[:alnum:]]\{12\}' > /dev/null; then
		# We've got a tag that looks like: v0.0.0-20180624165032-615eaa47ef79
		tag=$(echo ${revision} | awk -F- '$3 > 0 {print substr($3,1,7)}')
	elif echo ${revision} | grep '+incompatible' > /dev/null; then
		# We've got something like v2.3.5+incompatible
		tag=$(echo ${revision} | awk -F+ '{print $1}')
	fi
	
	#echo "${account}:${repo}:${tag}:${group}/src/${url}"
	printf '\t\t%s:%s:%s:%s/src/%s\n' "${account}" "${repo}" "${tag}" "${group}" "${url}"
	
done | awk 'NR>1{print prev " \\"} {prev=$0} END{ if (NR) print prev (prev == "" ? "" : "") }'

