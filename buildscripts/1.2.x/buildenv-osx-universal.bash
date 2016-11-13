#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# Set up the new build environment
cd buildenv/1.2.x/osx-universal
BUILDENV_DIR=$(./setup.command --non-interactive)
BUILDENV_BUILD_DIR="${BUILDENV_DIR}.build"

# Add a cleanup handler on error.
# Clean up the remains of the build
# environment on failure.
#
# Note: This isn't invoked if a build
# is manually stopped via Jenkins.
function cleanup {
  rm -rf ${BUILDENV_DIR}
  rm -rf ${BUILDENV_BUILD_DIR}
}
trap cleanup ERR

# Initiate the build.
source ${BUILDENV_DIR}/env
cd ${MUMBLE_PREFIX}/mumble-releng/buildenv/1.2.x/osx-universal
./build-all.bash

if [ -n "${MUMBLE_BUILDENV_TARSNAP}" ] && [ "${MUMBLE_BUILDENV_TARSNAP}" == "1" ]; then
	# Make a Tarsnap of the just-built build environment.
	BUILDENV_NAME=$(basename "${BUILDENV_DIR}")
	tarsnap -c -f "${BUILDENV_NAME}" "${BUILDENV_DIR}"

	# Make a Tarsnap of the build environment's .build directory.
	BUILDENV_BUILD_NAME=$(basename "${BUILDENV_BUILD_DIR}")
	tarsnap -c -f "${BUILDENV_BUILD_NAME}" "${BUILDENV_BUILD_DIR}"
fi

# Clean up the .build directory.
${MUMBLE_PREFIX}/mumble-releng/tools/cleanup-buildenv-build-dir.py "${BUILDENV_BUILD_DIR}"

# Update the build env symlink and get rid of
# the old build env.
if [ -L /MumbleBuild/latest-1.2.x ]; then
    # First, read the link.
    OLD_BUILDENV_DIR=$(readlink /MumbleBuild/latest-1.2.x)
    OLD_BUILDENV_BUILD_DIR="${OLD_BUILDENV_DIR}.build"
    rm -rf "${OLD_BUILDENV_DIR}"
    rm -rf "${OLD_BUILDENV_BUILD_DIR}"
    unlink /MumbleBuild/latest-1.2.x
fi
ln -sf ${BUILDENV_DIR} /MumbleBuild/latest-1.2.x
