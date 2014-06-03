#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source /MumbleBuild/latest-1.2.x/env
ver=$(git describe)

if [ "${MUMBLE_BUILD_TYPE}" == "Release" ]; then
    qmake -recursive CONFIG+="release static universal no-pch no-server no-dbus" DEFINES+="MUMBLE_VERSION=${ver}" main.pro
else
    qmake -recursive CONFIG+="release static universal no-pch no-server no-dbus" DEFINES+="MUMBLE_VERSION=${ver} SNAPSHOT_BUILD=1" main.pro
fi

make
./macx/scripts/osxdist.py --universal
