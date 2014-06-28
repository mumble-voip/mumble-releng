#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.xz"
expect_sha1 "libogg-1.3.1.tar.xz" "a4242415a7a9fd71f3092af9ff0b9fa630e4d7bd"
expect_sha256 "libogg-1.3.1.tar.xz" "3a5bad78d81afb78908326d11761c0fb1a0662ee7150b6ad587cc586838cdcfa"

tar -Jxf libogg-1.3.1.tar.xz
cd libogg-1.3.1
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/ogg-static-vs2010-Zi.patch

# Generate config_types.h so we can use the MSVS2010 libogg with MinGW.
./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --disable-shared --enable-static --with-pic
make
make install
