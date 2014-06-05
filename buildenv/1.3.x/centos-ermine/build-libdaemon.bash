#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "https://distfiles.macports.org/libdaemon/libdaemon-0.14.tar.gz" # unofficial; 0pointer.de was down for a couple of days
expect_sha1 "libdaemon-0.14.tar.gz" "78a4db58cf3a7a8906c35592434e37680ca83b8f"
expect_sha256 "libdaemon-0.14.tar.gz" "fd23eb5f6f986dcc7e708307355ba3289abe03cc381fc47a80bca4a50aa6b834"

tar -zxf libdaemon-0.14.tar.gz
cd libdaemon-0.14
./configure --prefix=$MUMBLE_PREFIX
make
make install
