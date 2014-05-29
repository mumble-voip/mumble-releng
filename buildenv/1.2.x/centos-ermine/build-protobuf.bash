#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://protobuf.googlecode.com/files/protobuf-2.5.0.tar.bz2"
expect_sha1 "protobuf-2.5.0.tar.bz2" "62c10dcdac4b69cc8c6bb19f73db40c264cb2726"
expect_sha256 "protobuf-2.5.0.tar.bz2" "13bfc5ae543cf3aa180ac2485c0bc89495e3ae711fc6fab4f8ffe90dfb4bb677"

tar -jxf protobuf-2.5.0.tar.bz2
cd protobuf-2.5.0
./configure --prefix=${MUMBLE_PREFIX}
make
make install
