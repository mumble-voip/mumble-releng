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
	if [ "$(shasum -a 1 ${FN} | cut -b -40)" != "${EXPECTED}" ]; then
		echo ${FN} sha1 mismatch
		exit
	fi
}

function expect_sha256 {
	FN=${1}
	EXPECTED=${2}
	if [ "$(shasum -a 256 ${FN} | cut -b -64)" != "${EXPECTED}" ]; then
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

# Convert the $VSVER variable into something
# bash's comparison operators can work with.
VSMAJOR=$(echo $VSVER | sed 's,\.0,,')

# If we're on MSVS2012 or greater, set us
# up to use /arch:IA32 to force pure IA32
# binaries (no SSE/SSE2/AVX) to be
# generated during our build.
if [ ${VSMAJOR} -gt 11 ]; then
	export CL="/arch:IA32 ${CL}"
fi

# Set the buildenv root and switch to it.
MUMBLE_BUILDENV_ROOT=${PWD}
cd ${MUMBLE_PREFIX_BUILD}