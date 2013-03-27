#!/bin/bash
set -e
SHA1="4aa358a95d1e5774603e6fa149c926a80df43559"
curl -O "http://zlib.net/zlib-1.2.7.tar.gz"
if [ "$(sha1sum zlib-1.2.7.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo zlib checksum mismatch
	exit
fi
tar -zxf zlib-1.2.7.tar.gz
cd zlib-1.2.7
./configure --prefix=${MUMBLE_PREFIX}
make
make install
