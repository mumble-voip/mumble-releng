#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz"
expect_sha1 "libsndfile-1.0.25.tar.gz" "e95d9fca57f7ddace9f197071cbcfb92fa16748e"
expect_sha256 "libsndfile-1.0.25.tar.gz" "59016dbd326abe7e2366ded5c344c853829bebfd1702ef26a07ef662d6aa4882"

tar -zxf libsndfile-1.0.25.tar.gz
cd libsndfile-1.0.25
patch -p1 <<EOF
--- ./programs/sndfile-play.c
+++ ./programs/sndfile-play.c
@@ -58,7 +58,7 @@
 	#include 	<sys/soundcard.h>
 
 #elif (defined (__MACH__) && defined (__APPLE__))
-	#include <Carbon.h>
+	#include <Carbon/Carbon.h>
 	#include <CoreAudio/AudioHardware.h>
 
 #elif defined (HAVE_SNDIO_H)
EOF

export CFLAGS="${OSX_TARGET_CFLAGS} -arch ppc"
export CXXFLAGS="${OSX_TARGET_CXXFLAGS} -arch ppc"
export LDFLAGS="${OSX_TARGET_LDFLAGS} -arch ppc"

./configure --prefix=${MUMBLE_PREFIX} --disable-dependency-tracking --disable-shared --enable-static --disable-sqlite
make
make install

cp ${MUMBLE_PREFIX}/lib/libsndfile.a ${MUMBLE_PREFIX}/lib/libsndfile-ppc.a

export CFLAGS="${OSX_TARGET_CFLAGS} -arch i386"
export CXXFLAGS="${OSX_TARGET_CXXFLAGS} -arch i386"
export LDFLAGS="${OSX_TARGET_LDFLAGS} -arch i386"

make distclean
./configure --prefix=${MUMBLE_PREFIX} --disable-dependency-tracking --disable-shared --enable-static --disable-sqlite
make
make install

cp ${MUMBLE_PREFIX}/lib/libsndfile.a ${MUMBLE_PREFIX}/lib/libsndfile-i386.a

cd ${MUMBLE_PREFIX}/lib/
lipo -create -arch ppc libsndfile-ppc.a -arch i386 libsndfile-i386.a -output libsndfile.a

sed -i '' -e 's,Libs.private.*,Requires.private: vorbisenc flac,g' ${MUMBLE_PREFIX}/lib/pkgconfig/sndfile.pc