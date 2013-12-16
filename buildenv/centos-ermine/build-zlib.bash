#!/bin/bash
set -e
SHA1="a4d316c404ff54ca545ea71a27af7dbc29817088"
curl -O "http://zlib.net/zlib-1.2.8.tar.gz"
if [ "$(sha1sum zlib-1.2.8.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo zlib checksum mismatch
	exit
fi
tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure --prefix=${MUMBLE_PREFIX}
make
make install
