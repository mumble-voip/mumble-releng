#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://zlib.net/zlib-1.2.8.tar.gz"
expect_sha1 "zlib-1.2.8.tar.gz" "a4d316c404ff54ca545ea71a27af7dbc29817088"

tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8

patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/zlib-safeseh.patch

cmd /c nmake -f win32/Makefile.msc LOC="-DASMV -DASMINF" OBJA="inffas32.obj match686.obj"

mkdir -p ${MUMBLE_PREFIX}/zlib/{lib,include}

cp zdll.lib ${MUMBLE_PREFIX}/zlib/lib/
cp zlib1.dll ${MUMBLE_PREFIX}/zlib/lib/
cp zlib.h zconf.h ${MUMBLE_PREFIX}/zlib/include/
