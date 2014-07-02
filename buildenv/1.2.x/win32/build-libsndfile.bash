#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz"
expect_sha1 "libsndfile-1.0.25.tar.gz" "e95d9fca57f7ddace9f197071cbcfb92fa16748e"

tar -zxf libsndfile-1.0.25.tar.gz
cd libsndfile-1.0.25
./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --enable-shared --with-pic --disable-sqlite
make LDFLAGS="-Wl,-lFLAC -Wl,-lvorbisenc -Wl,-lvorbis -Wl,-lvorbisfile, -Wl,-logg"
make install

echo "LIBRARY libsndfile-1" > libsndfile-1.def
echo "EXPORTS" >> libsndfile-1.def
cmd /c dumpbin.exe /exports $(cygpath -w "${MUMBLE_SNDFILE_PREFIX}/bin/libsndfile-1.dll") | grep "sf_" | sed 's,.*\ sf,sf,' >> libsndfile-1.def
cmd /c lib.exe /machine:x86 /def:libsndfile-1.def /out:libsndfile-1.lib
cp libsndfile-1.lib ${MUMBLE_SNDFILE_PREFIX}/lib/
