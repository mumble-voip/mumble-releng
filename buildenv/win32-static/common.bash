#!/bin/bash

function fetch_if_not_exists {
	URL=${1}
	FN=$(basename ${URL})
	if [ ! -f "${FN}" ]; then
		curl -L -O ${URL}
	fi
}

function expect_sha1 {
	FN=${1}
	EXPECTED=${2}
	if [ "$(sha1sum ${FN} | cut -b -40)" != "${EXPECTED}" ]; then
		echo ${FN} sha1 mismatch
		exit
	fi
}

if [ "${MUMBLE_PREFIX}" == "" ]; then
	echo "\$MUMBLE_PREFIX is not set."
	exit
fi

if [ "${MUMBLE_PREFIX_BUILD}" == "" ]; then
	echo "\$MUMBLE_PREFIX_BUILD is not set."
	exit
fi

MUMBLE_BUILDENV_ROOT=${PWD}
cd ${MUMBLE_PREFIX_BUILD}