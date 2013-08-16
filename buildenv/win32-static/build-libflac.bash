#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/flac/flac-1.2.1.tar.gz"
expect_sha1 "flac-1.2.1.tar.gz" "bd54354900181b59db3089347cc84ad81e410b38"

tar -zxf flac-1.2.1.tar.gz
cd flac-1.2.1
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/flac-alloch.patch
./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --disable-shared --enable-static
make
make install
