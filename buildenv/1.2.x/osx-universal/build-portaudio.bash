#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.portaudio.com/archives/pa_stable_v19_20111121.tgz"
expect_sha1 "pa_stable_v19_20111121.tgz" "f07716c470603729a55b70f5af68f4a6807097eb"
expect_sha256 "pa_stable_v19_20111121.tgz" "9c26d1330d506496789edafe55b0386f20d83c4aa2c0e3f81fbeb0f114ab1b99"

tar -zxf pa_stable_v19_20111121.tgz
cd portaudio
./configure --prefix=${MUMBLE_PREFIX} --disable-shared --enable-static --enable-mac-universal
make
make install
