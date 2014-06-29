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
cp ${MUMBLE_SNDFILE_PREFIX}/lib/libsndfile.dll.a ${MUMBLE_SNDFILE_PREFIX}/lib/libsndfile-1.lib
