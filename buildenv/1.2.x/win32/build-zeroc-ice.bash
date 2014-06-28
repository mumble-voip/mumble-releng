#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.zeroc.com/download/Ice/3.4/Ice-3.4.2.zip"
expect_sha1 "Ice-3.4.2.zip" "e59f6f806a70bbd22513cc85154b4281da9915cd"
expect_sha256 "Ice-3.4.2.zip" "6c95c6176631382d2c9bdb66416fce1c747324dc06ef11c6588e4c177836233c"

unzip -q -o Ice-3.4.2.zip
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

patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/Ice-3.4.2-Make.rules.msvc-db5.patch

cd cpp

export ICE_LDFLAGS="/LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/mcpp) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/bzip2/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/expat/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/berkeleydb/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/Qt4.8/lib)"
export ICE_CPPFLAGS="/I$(cygpath -w ${MUMBLE_PREFIX}/bzip2/include) /I$(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/include) /I$(cygpath -w ${MUMBLE_PREFIX}/expat/include) /I$(cygpath -w ${MUMBLE_PREFIX}/berkeleydb/include) /I$(cygpath -w ${MUMBLE_PREFIX}/Qt4.8/include)"

sed -i -re "s,^prefix.*,prefix=$(echo $(cygpath -w ${MUMBLE_PREFIX}/ZeroC-Ice) | sed 's,\\,\\\\,g'),g" config/Make.rules.mak
sed -i -re "s,^CPP_COMPILER.*,CPP_COMPILER=VC100_EXPRESS,g" config/Make.rules.mak
sed -i -re 's,^#OPTIMIZE,OPTIMIZE,g' config/Make.rules.mak
sed -i -re 's,^#RELEASEPDBS,RELEASEPDBS,g' config/Make.rules.mak

cmd /c nmake /f Makefile.mak THIRDPARTY_HOME="$(cygpath -w ${MUMBLE_PREFIX}/IceThirdPartyNonExistant)" LDFLAGS="${ICE_LDFLAGS}" CPPFLAGS="${ICE_CPPFLAGS}" 
cmd /c nmake /f Makefile.mak install
