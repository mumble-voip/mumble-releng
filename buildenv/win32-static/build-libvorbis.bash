#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.3.tar.gz"
expect_sha1 "libvorbis-1.3.3.tar.gz" "8dae60349292ed76db0e490dc5ee51088a84518b"

tar -zxf libvorbis-1.3.3.tar.gz
cd libvorbis-1.3.3
./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --disable-shared --enable-static
make
make install
