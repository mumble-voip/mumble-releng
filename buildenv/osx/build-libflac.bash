#!/bin/bash
SHA1="a136e5748f8fb1e6c524c75000a765fc63bb7b1b"
curl -O "http://downloads.xiph.org/releases/flac/flac-1.3.0.tar.xz"
if [ "$(shasum -a 1 flac-1.3.0.tar.xz | cut -b -40)" != "${SHA1}" ]; then
	echo flac checksum mismatch
	exit
fi
xzcat flac-1.3.0.tar.xz | tar -xf -
cd flac-1.3.0
./configure --build=x86_64-apple-darwin$(uname -r) --prefix=$MUMBLE_PREFIX --disable-shared --enable-static
make
make install
