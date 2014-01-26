#!/bin/bash
SHA1="f7aeaa76a043ab9c1cd5899d09c696d98278e2d7"
curl -O "http://www.openssl.org/source/openssl-1.0.0l.tar.gz"
if [ "$(shasum -a 1 openssl-1.0.0l.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo openssl checksum mismatch
	exit
fi
tar -zxf openssl-1.0.0l.tar.gz
cd openssl-1.0.0l
./Configure darwin64-x86_64-cc no-shared --prefix=$MUMBLE_PREFIX --openssldir=$MUMBLE_PREFIX/openssl
make
make install
