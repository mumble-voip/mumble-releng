#!/bin/bash
SHA1="ec5d20f1ee52ae765b9286e9d7951dcfc9548607"
curl -O http://www.openssl.org/source/openssl-1.0.0k.tar.gz
if [ "$(sha1sum openssl-1.0.0k.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo openssl checksum mismatch
	exit
fi
tar -zxf openssl-1.0.0k.tar.gz
cd openssl-1.0.0k
./Configure linux-elf shared zlib threads --prefix=$MUMBLE_PREFIX --openssldir=$MUMBLE_PREFIX/openssl -L$MUMBLE_PREFIX/lib -I$MUMBLE_PREFIX/include
make
make install
