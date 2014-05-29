#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://tukaani.org/xz/xz-5.0.5.tar.gz"
expect_sha1 "xz-5.0.5.tar.gz" "26fec2c1e409f736e77a85e4ab314dc74987def0"
expect_sha256 "xz-5.0.5.tar.gz" "5dcffe6a3726d23d1711a65288de2e215b4960da5092248ce63c99d50093b93a"

tar -zxf xz-5.0.5.tar.gz
cd xz-5.0.5
./configure --prefix=${MUMBLE_PREFIX}
make
make install
