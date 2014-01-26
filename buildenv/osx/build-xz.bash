#!/bin/bash
SHA1="26fec2c1e409f736e77a85e4ab314dc74987def0"
curl -L -O "http://tukaani.org/xz/xz-5.0.5.tar.gz"
if [ "$(shasum -a 1 xz-5.0.5.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo xz checksum mismatch
	exit
fi
tar -zxf xz-5.0.5.tar.gz
cd xz-5.0.5
./configure --prefix=${MUMBLE_PREFIX}
make
make install
