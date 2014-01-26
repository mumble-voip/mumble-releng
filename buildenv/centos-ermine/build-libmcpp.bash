#!/bin/bash
set -e
SHA1="703356b7c2cd30d7fb6000625bf3ccc2eb977ecb"
curl -L -O "http://downloads.sourceforge.net/project/mcpp/mcpp/V.2.7.2/mcpp-2.7.2.tar.gz"
if [ "$(sha1sum mcpp-2.7.2.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libmcpp checksum mismatch
	exit
fi
tar -zxf mcpp-2.7.2.tar.gz
cd mcpp-2.7.2
patch -p1 < ../patches/zeroc-patch.mcpp.2.7.2
./configure --prefix=$MUMBLE_PREFIX --enable-mcpplib
make
make install
