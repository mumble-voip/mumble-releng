#!/bin/bash
SHA1="f7aeaa76a043ab9c1cd5899d09c696d98278e2d7"
curl -O "http://www.openssl.org/source/openssl-1.0.0l.tar.gz"
if [ "$(sha1sum openssl-1.0.0l.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo openssl checksum mismatch
	exit
fi
tar -zxf openssl-1.0.0l.tar.gz
cd openssl-1.0.0l
./Configure linux-elf shared zlib threads --prefix=$MUMBLE_PREFIX --openssldir=$MUMBLE_PREFIX/openssl -L$MUMBLE_PREFIX/lib -I$MUMBLE_PREFIX/include
make
make install
