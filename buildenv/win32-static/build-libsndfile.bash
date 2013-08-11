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
./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --disable-shared --enable-static --disable-sqlite
cp src/config.h src/config.h.orig

# Avoid gettimeofday() and snprintf(), which
# would require linking against libmingwex.a.
cat src/config.h.orig | grep -v HAVE_GETTIMEOFDAY > src/config.h
echo "#define HAVE_GETTIMEOFDAY 0" >> src/config.h

cd src	
make
make install
