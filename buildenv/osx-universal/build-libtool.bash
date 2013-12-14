#!/bin/bash
SHA1="22b71a8b5ce3ad86e1094e7285981cae10e6ff88"
curl -L -O "http://ftpmirror.gnu.org/libtool/libtool-2.4.2.tar.gz"
if [ "$(shasum -a 1 libtool-2.4.2.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libtool checksum mismatch
	exit
fi
tar -zxf libtool-2.4.2.tar.gz
cd libtool-2.4.2
./configure --prefix=${MUMBLE_PREFIX} --program-prefix=g --enable-ltdl-install --disable-dependency-tracking
make
make install
