#!/bin/bash
SHA1="bd54354900181b59db3089347cc84ad81e410b38"
curl -O "http://downloads.xiph.org/releases/flac/flac-1.2.1.tar.gz"
if [ "$(shasum -a 1 flac-1.2.1.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo flac checksum mismatch
	exit
fi
tar -zxf flac-1.2.1.tar.gz
cd flac-1.2.1
./configure --build=x86_64-apple-darwin$(uname -r) --prefix=$MUMBLE_PREFIX --disable-shared --enable-static
make
make install
