#!/bin/bash
set -e
SHA1="3f89f861209ce81a6bab1fd1998c0ef311712002"
curl -O "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
if [ "$(sha1sum bzip2-1.0.6.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo bzip2 checksum mismatch
	exit
fi
tar -zxf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
make
make PREFIX=${MUMBLE_PREFIX} install
make clean
make -f Makefile-libbz2_so
cp libbz2.so.1.0.6 ${MUMBLE_PREFIX}/lib/
cd ${MUMBLE_PREFIX}/lib/
ln -sf libbz2.so.1.0.6 libbz2.so.1.0
ln -sf libbz2.so.1.0.6 libbz2.so.1
ln -sf libbz2.so.1.0.6 libbz2.so
