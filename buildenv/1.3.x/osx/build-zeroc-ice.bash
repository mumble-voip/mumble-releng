#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.zeroc.com/download/Ice/3.4/Ice-3.4.2.tar.gz"
expect_sha1 "Ice-3.4.2.tar.gz" "8c84d6e3b227f583d05e08251e07047e6c3a6b42"
expect_sha256 "Ice-3.4.2.tar.gz" "dcf0484495b6df0849ec90a00e8204fe5fe1c0d3882bb438bf2c1d062f15c979"

tar -zxf Ice-3.4.2.tar.gz
cd Ice-3.4.2
patch -p1 <<EOF
--- ./cpp/src/Freeze/MapI.cpp   
+++ ./cpp/src/Freeze/MapI.cpp                                      
@@ -1487,10 +1487,10 @@ Freeze::MapHelperI::size() const

     try
     {
-#if DB_VERSION_MAJOR != 4
-#error Freeze requires DB 4.x
+#if DB_VERSION_MAJOR < 4
+#error Freeze requires DB 4.x or greater
 #endif
-#if DB_VERSION_MINOR < 3
+#if DB_VERSION_MAJOR == 4 && DB_VERSION_MINOR < 3
         _db->stat(&s, 0);
 #else
         _db->stat(_connection->dbTxn(), &s, 0);
EOF
patch -p0 < ${MUMBLE_BUILDENV_ROOT}/patches/ice_for_clang_c++11_libc++_2012-09-14.patch.txt
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/Ice-3.4.2-Darwin-static.patch
cd cpp
make prefix=${ICE_PREFIX} STATICLIBS=yes OPTIMIZE=yes CXX="${CXX} ${OSX_CFLAGS}" CC="${CC} ${OSX_CFLAGS}" DB_HOME=${MUMBLE_PREFIX} MCPP_HOME=${MUMBLE_PREFIX}
make prefix=${ICE_PREFIX} STATICLIBS=yes OPTIMIZE=yes CXX="${CXX} ${OSX_CFLAGS}" CC="${CC} ${OSX_CFLAGS}" DB_HOME=${MUMBLE_PREFIX} MCPP_HOME=${MUMBLE_PREFIX} depend
make prefix=${ICE_PREFIX} STATICLIBS=yes OPTIMIZE=yes CXX="${CXX} ${OSX_CFLAGS}" CC="${CC} ${OSX_CFLAGS}" DB_HOME=${MUMBLE_PREFIX} MCPP_HOME=${MUMBLE_PREFIX}
make prefix=${ICE_PREFIX} STATICLIBS=yes OPTIMIZE=yes CXX="${CXX} ${OSX_CFLAGS}" CC="${CC} ${OSX_CFLAGS}" DB_HOME=${MUMBLE_PREFIX} MCPP_HOME=${MUMBLE_PREFIX} install
