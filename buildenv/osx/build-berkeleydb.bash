#!/bin/bash
SHA1="fa3f8a41ad5101f43d08bc0efb6241c9b6fc1ae9"
curl -O "http://download.oracle.com/berkeley-db/db-5.3.28.tar.gz"
if [ "$(shasum -a 1 db-5.3.28.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo berkeleydb checksum mismatch
	exit
fi
tar -zxf db-5.3.28.tar.gz
cd db-5.3.28
patch -p1 < ../patches/db-5.3.21-clang.patch
cd build_unix
../dist/configure --prefix=$MUMBLE_PREFIX --disable-shared --enable-static --enable-cxx
make
make install
