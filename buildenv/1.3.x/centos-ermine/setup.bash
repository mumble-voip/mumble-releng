#!/bin/bash
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

cd "$(dirname ${0})"

if [ ! -d "/MumbleBuild" ]; then
	echo "No /MumbleBuild directory exists on this machine."
	echo
	echo "The Mumble 'centos-ermine' build environment stores its installed"
	echo "products in a directory in the filesystem root for security"
	echo "and reproduciblity reasons."
	echo
	echo "Please create a /MumbleBuild directory and make it writable"
	echo "by your user:"
	echo "   sudo mkdir -p /MumbleBuild"
	echo "   sudo chown \$USER:wheel /MumbleBuild"
	exit 1
fi

BUILDENV_NAME="$(./setup/name.bash)"
BUILDENV_TARGET="/MumbleBuild/${BUILDENV_NAME}"

if [ -d "${BUILDENV_TARGET}" ]; then
	echo "A build environment with the name ${BUILDENV_NAME}"
	echo "already exists in /MumbleBuild."
	echo
	echo "Installation aborted."
	exit 1
fi

mkdir -p "${BUILDENV_TARGET}"
mkdir -p "${BUILDENV_TARGET}.build"
cp ./setup/env "${BUILDENV_TARGET}"

MUMBLE_RELENG="$(git rev-parse --show-toplevel 2>/dev/null)"
GIT_TARGET="${BUILDENV_TARGET}/mumble-releng"
git clone --recursive "${MUMBLE_RELENG}" "${GIT_TARGET}" 2>/dev/null 1>/dev/null

if [[ $* == *--non-interactive* ]]; then
	echo "${BUILDENV_TARGET}"
else
	echo "Successfully installed build environment"
	echo "into ${BUILDENV_TARGET}."
fi