#!/bin/bash
SHA1="62c10dcdac4b69cc8c6bb19f73db40c264cb2726"
curl -O "http://protobuf.googlecode.com/files/protobuf-2.5.0.tar.bz2"
if [ "$(shasum -a 1 protobuf-2.5.0.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo protobuf checksum mismatch
	exit
fi
tar -jxf protobuf-2.5.0.tar.bz2
cd protobuf-2.5.0
./configure --disable-dependency-tracking --prefix=$MUMBLE_PREFIX --disable-shared --enable-static
make
make install
