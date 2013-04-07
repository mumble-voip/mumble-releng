#!/bin/bash
SHA1="ec5d20f1ee52ae765b9286e9d7951dcfc9548607"
curl -O http://www.openssl.org/source/openssl-1.0.0k.tar.gz
if [ "$(shasum -a 1 openssl-1.0.0k.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo openssl checksum mismatch
	exit
fi
tar -zxf openssl-1.0.0k.tar.gz
cd openssl-1.0.0k
./Configure darwin64-x86_64-cc no-shared --prefix=$MUMBLE_PREFIX --openssldir=$MUMBLE_PREFIX/openssl
make
make install
