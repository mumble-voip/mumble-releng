#!/bin/bash -ex
SHA1="b08197d146930a5543a7b99e871cba3da614f6f0"
curl -L -O "http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz"
if [ "$(sha1sum expat-2.1.0.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo expat checksum mismatch
	exit
fi
tar -zxf expat-2.1.0.tar.gz
cd expat-2.1.0
./configure --prefix=$MUMBLE_PREFIX
make
make install
