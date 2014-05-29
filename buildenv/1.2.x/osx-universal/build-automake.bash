#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://ftpmirror.gnu.org/automake/automake-1.14.tar.gz"
expect_sha1 "automake-1.14.tar.gz" "648f7a3cf8473ff6aa433c7721cab1c7fae8d06c"
expect_sha256 "automake-1.14.tar.gz" "7847424d4204d1627c129e9c15b81e145836afa2a1bf9003ffe10aa26ea75755"

tar -zxf automake-1.14.tar.gz
cd automake-1.14
./configure --prefix=${MUMBLE_PREFIX} --disable-dependency-tracking
make
make install
