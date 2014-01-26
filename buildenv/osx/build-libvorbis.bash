#!/bin/bash
SHA1="1602716c187593ffe4302124535240cec2079df3"
curl -O "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz"
if [ "$(shasum -a 1 libvorbis-1.3.4.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libvorbis checksum mismatch
	exit
fi
tar -zxf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
./configure --disable-dependency-tracking --prefix=$MUMBLE_PREFIX --disable-shared --enable-static
make
make install
