#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# Convert Windows paths to Unix paths.
export BUILDENV_DIR=$(cygpath -u ${BUILDENV_DIR})
export BUILDENV_BUILD_DIR=$(cygpath -u ${BUILDENV_BUILD_DIR})

# Add a cleanup handler on error.
# Clean up the remains of the build
# environment on failure.
#
# Note: This isn't invoked if a build
# is manually stopped via Jenkins.
function cleanup {
  cd "${HOME}"
  rm -rf "${BUILDENV_DIR}"
  rm -rf "${BUILDENV_BUILD_DIR}"
}
trap cleanup ERR

# Initiate the build.
source ${BUILDENV_DIR}/env
cd ${MUMBLE_PREFIX}/mumble-releng/buildenv/1.3.x/win32
./build-all.bash

# Make a Tarsnap of the just-built build environment.
BUILDENV_NAME=$(basename "${BUILDENV_DIR}")
tarsnap -c -f "${BUILDENV_NAME}" "${BUILDENV_DIR}"

# Make a Tarsnap of the build environment's .build directory.
BUILDENV_BUILD_NAME=$(basename "${BUILDENV_BUILD_DIR}")
tarsnap -c -f "${BUILDENV_BUILD_NAME}" "${BUILDENV_BUILD_DIR}"

# Clean up the .build directory.
cmd /c python.exe $(cygpath -w ${MUMBLE_PREFIX}/mumble-releng/tools/cleanup-buildenv-build-dir.py) "$(cygpath -w ${BUILDENV_BUILD_DIR})"

# Update the build env symlink and get rid of
# the old build env.
LATEST_SYMLINK_PATH="$(cygpath -u c:\\MumbleBuild\\latest-1.3.x)"
if [ -L "${LATEST_SYMLINK_PATH}" ]; then
    # First, read the link.
    OLD_BUILDENV_DIR="$(readlink ${LATEST_SYMLINK_PATH})"
    OLD_BUILDENV_BUILD_DIR="${OLD_BUILDENV_DIR}.build"
    rm -rf "${OLD_BUILDENV_DIR}"
    rm -rf "${OLD_BUILDENV_BUILD_DIR}"
    unlink "${LATEST_SYMLINK_PATH}"
fi
cmd /c mklink /j c:\\MumbleBuild\\latest-1.3.x "$(cygpath -w ${BUILDENV_DIR})"
