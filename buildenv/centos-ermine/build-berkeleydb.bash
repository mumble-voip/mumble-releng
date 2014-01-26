#!/bin/bash
set -e
SHA1="fa3f8a41ad5101f43d08bc0efb6241c9b6fc1ae9"
curl -O "http://download.oracle.com/berkeley-db/db-5.3.28.tar.gz"
if [ "$(sha1sum db-5.3.28.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo berkeleydb checksum mismatch
	exit
fi
tar -zxf db-5.3.28.tar.gz
cd db-5.3.28/build_unix
../dist/configure --prefix=$MUMBLE_PREFIX --enable-cxx
make
make install
