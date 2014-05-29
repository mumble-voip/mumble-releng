#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/flac/flac-1.3.0.tar.xz"
expect_sha1 "flac-1.3.0.tar.xz" "a136e5748f8fb1e6c524c75000a765fc63bb7b1b"
expect_sha256 "flac-1.3.0.tar.xz" "fa2d64aac1f77e31dfbb270aeb08f5b32e27036a52ad15e69a77e309528010dc"

xzcat flac-1.3.0.tar.xz | tar -xf -
cd flac-1.3.0
./configure --build=x86_64-apple-darwin$(uname -r) --prefix=${MUMBLE_PREFIX} --disable-shared --enable-static
make
make install
