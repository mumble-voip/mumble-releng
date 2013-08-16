#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/ogg/libogg-1.3.0.tar.gz"
expect_sha1 "libogg-1.3.0.tar.gz" "a900af21b6d7db1c7aa74eb0c39589ed9db991b8"

tar -zxf libogg-1.3.0.tar.gz
cd libogg-1.3.0
./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --disable-shared --enable-static
make
make install
