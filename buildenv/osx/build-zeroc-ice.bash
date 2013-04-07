#!/bin/bash
SHA1="8c84d6e3b227f583d05e08251e07047e6c3a6b42"
curl -L -O "http://www.zeroc.com/download/Ice/3.4/Ice-3.4.2.tar.gz"
if [ "$(shasum -a 1 Ice-3.4.2.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo zeroc ice checksum mismatch
	exit
fi
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
patch -p0 < ../patches/ice_for_clang_c++11_libc++_2012-09-14.patch.txt
patch -p1 < ../patches/Ice-3.4.2-Darwin-static.patch
cd cpp
make prefix=$ICE_PREFIX STATICLIBS=yes OPTIMIZE=yes CXX="$CXX $OSX_CFLAGS" CC="$CC $OSX_CFLAGS" DB_HOME=$MUMBLE_PREFIX MCPP_HOME=$MUMBLE_PREFIX
make prefix=$ICE_PREFIX STATICLIBS=yes OPTIMIZE=yes CXX="$CXX $OSX_CFLAGS" CC="$CC $OSX_CFLAGS" DB_HOME=$MUMBLE_PREFIX MCPP_HOME=$MUMBLE_PREFIX depend
make prefix=$ICE_PREFIX STATICLIBS=yes OPTIMIZE=yes CXX="$CXX $OSX_CFLAGS" CC="$CC $OSX_CFLAGS" DB_HOME=$MUMBLE_PREFIX MCPP_HOME=$MUMBLE_PREFIX
make prefix=$ICE_PREFIX STATICLIBS=yes OPTIMIZE=yes CXX="$CXX $OSX_CFLAGS" CC="$CC $OSX_CFLAGS" DB_HOME=$MUMBLE_PREFIX MCPP_HOME=$MUMBLE_PREFIX install
