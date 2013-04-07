#!/bin/bash
SHA1="a900af21b6d7db1c7aa74eb0c39589ed9db991b8"
curl -O "http://downloads.xiph.org/releases/ogg/libogg-1.3.0.tar.gz"
if [ "$(shasum -a 1 libogg-1.3.0.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libogg checksum mismatch
	exit
fi
tar -zxf libogg-1.3.0.tar.gz
cd libogg-1.3.0
./configure --disable-dependency-tracking --prefix=$MUMBLE_PREFIX --disable-shared --enable-static
make
make install
