#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz"
expect_sha1 "libogg-1.3.1.tar.gz" "270685c2a3d9dc6c98372627af99868aa4b4db53"
expect_sha256 "libogg-1.3.1.tar.gz" "4e343f07aa5a1de8e0fa1107042d472186b3470d846b20b115b964eba5bae554"

tar -zxf libogg-1.3.1.tar.gz
cd libogg-1.3.1
./configure --disable-dependency-tracking --prefix=${MUMBLE_PREFIX} --disable-shared --enable-static
make
make install
