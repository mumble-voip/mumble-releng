#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source /MumbleBuild/latest-1.2.x/env
ver=$(python /MumbleBuild/latest-1.2.x/mumble-releng/tools/mumble-version.py)

# Use Qt 5
#export PATH="$HOME/MumbleBuild/Qt5.1/bin:$PATH"
#export QMAKE_EXTRA=""

# Use Qt 4
export QMAKE_EXTRA="-spec unsupported/macx-clang"

if [ "${MUMBLE_BUILD_TYPE}" == "Release" ]; then
    qmake -recursive ${QMAKE_EXTRA} CONFIG+="release static no-server no-dbus no-portaudio" DEFINES+="MUMBLE_VERSION=${ver}" main.pro
else
    qmake -recursive ${QMAKE_EXTRA} CONFIG+="release static no-server no-dbus no-portaudio" DEFINES+="MUMBLE_VERSION=${ver} SNAPSHOT_BUILD=1" main.pro
fi

make
./macx/scripts/osxdist.py
