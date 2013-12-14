#!/bin/bash
SHA1="e95d9fca57f7ddace9f197071cbcfb92fa16748e"
curl -O "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz"
if [ "$(shasum -a 1 libsndfile-1.0.25.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libsndfile checksum mismatch
	exit
fi
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

export CFLAGS="$OSX_TARGET_CFLAGS -arch ppc"
export CXXFLAGS="$OSX_TARGET_CXXFLAGS -arch ppc"
export LDFLAGS="$OSX_TARGET_LDFLAGS -arch ppc"

./configure --prefix=$MUMBLE_PREFIX --disable-dependency-tracking --disable-shared --enable-static --disable-sqlite
make
make install

cp $MUMBLE_PREFIX/lib/libsndfile.a $MUMBLE_PREFIX/lib/libsndfile-ppc.a

export CFLAGS="$OSX_TARGET_CFLAGS -arch i386"
export CXXFLAGS="$OSX_TARGET_CXXFLAGS -arch i386"
export LDFLAGS="$OSX_TARGET_LDFLAGS -arch i386"

make distclean
./configure --prefix=$MUMBLE_PREFIX --disable-dependency-tracking --disable-shared --enable-static --disable-sqlite
make
make install

cp $MUMBLE_PREFIX/lib/libsndfile.a $MUMBLE_PREFIX/lib/libsndfile-i386.a

cd $MUMBLE_PREFIX/lib/
lipo -create -arch ppc libsndfile-ppc.a -arch i386 libsndfile-i386.a -output libsndfile.a

