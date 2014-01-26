#!/bin/bash
SHA1="270685c2a3d9dc6c98372627af99868aa4b4db53"
curl -O "http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz"
if [ "$(shasum -a 1 libogg-1.3.1.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libogg checksum mismatch
	exit
fi
tar -zxf libogg-1.3.1.tar.gz
cd libogg-1.3.1
./configure --disable-dependency-tracking --prefix=$MUMBLE_PREFIX --disable-shared --enable-static
make
make install
