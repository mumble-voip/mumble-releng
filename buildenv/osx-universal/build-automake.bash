#!/bin/bash
SHA1="648f7a3cf8473ff6aa433c7721cab1c7fae8d06c"
curl -L -O "http://ftpmirror.gnu.org/automake/automake-1.14.tar.gz"
if [ "$(shasum -a 1 automake-1.14.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo automake checksum mismatch
	exit
fi
tar -zxf automake-1.14.tar.gz
cd automake-1.14
./configure --prefix=${MUMBLE_PREFIX} --disable-dependency-tracking
make
make install
