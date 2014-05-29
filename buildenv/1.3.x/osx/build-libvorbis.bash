#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz"
expect_sha1 "libvorbis-1.3.4.tar.gz" "1602716c187593ffe4302124535240cec2079df3"
expect_sha256 "libvorbis-1.3.4.tar.gz" "eee09a0a13ec38662ff949168fe897a25d2526529bc7e805305f381c219a1ecb"

tar -zxf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
./configure --disable-dependency-tracking --prefix=${MUMBLE_PREFIX} --disable-shared --enable-static
make
make install
