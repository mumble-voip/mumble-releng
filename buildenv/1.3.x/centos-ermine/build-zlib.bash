#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://zlib.net/zlib-1.2.8.tar.gz"
expect_sha1 "zlib-1.2.8.tar.gz" "a4d316c404ff54ca545ea71a27af7dbc29817088"
expect_sha256 "zlib-1.2.8.tar.gz" "36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d"

tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure --prefix=${MUMBLE_PREFIX}
make
make install
