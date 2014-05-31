#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://ftp.gwdg.de/pub/linux/sources.redhat.com/libffi/libffi-3.0.13.tar.gz"
expect_sha1 "libffi-3.0.13.tar.gz" "f5230890dc0be42fb5c58fbf793da253155de106"
expect_sha256 "libffi-3.0.13.tar.gz" "1dddde1400c3bcb7749d398071af88c3e4754058d2d4c0b3696c2f82dc5cf11c"

tar -zxf libffi-3.0.13.tar.gz
cd libffi-3.0.13
./configure --prefix=${MUMBLE_PREFIX}
make
make install
