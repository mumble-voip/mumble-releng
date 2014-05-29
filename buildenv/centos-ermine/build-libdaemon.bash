#!/bin/bash -ex
SHA1="78a4db58cf3a7a8906c35592434e37680ca83b8f"
curl -O "http://0pointer.de/lennart/projects/libdaemon/libdaemon-0.14.tar.gz"
if [ "$(sha1sum libdaemon-0.14.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libdaemon checksum mismatch
	exit
fi
tar -zxf libdaemon-0.14.tar.gz
cd libdaemon-0.14
./configure --prefix=$MUMBLE_PREFIX
make
make install
