#!/bin/bash
SHA1="df5867e37a4b51fb69f53a8baf5b994938691d6d"
curl -O "http://protobuf.googlecode.com/files/protobuf-2.4.1.tar.bz2"
if [ "$(shasum -a 1 protobuf-2.4.1.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo protobuf checksum mismatch
	exit
fi
tar -jxf protobuf-2.4.1.tar.bz2
cd protobuf-2.4.1
./configure --disable-dependency-tracking --prefix=$MUMBLE_PREFIX --disable-shared --enable-static
make
make install
