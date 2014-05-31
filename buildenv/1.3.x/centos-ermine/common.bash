#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

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
		echo "${FN} sha1 mismatch"
		exit 1
	fi
}

function expect_sha256 {
	FN=${1}
	EXPECTED=${2}
	if [ "$(sha256sum ${FN} | cut -b -64)" != "${EXPECTED}" ]; then
		echo "${FN} sha256 mismatch"
		exit 1
	fi
}

if [ "${MUMBLE_PREFIX}" == "" ]; then
	echo "\${MUMBLE_PREFIX} is not set."
	exit
fi

if [ "${MUMBLE_PREFIX_BUILD}" == "" ]; then
	echo "\${MUMBLE_PREFIX_BUILD} is not set."
	exit
fi

# Set the buildenv root and switch to it.
MUMBLE_BUILDENV_ROOT=${PWD}
cd ${MUMBLE_PREFIX_BUILD}