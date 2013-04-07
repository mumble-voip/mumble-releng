#!/bin/bash
SHA1="8922aeb4edeff7ed554cc1969cbb4ad5a4e6b26e"
curl -O http://pkgconfig.freedesktop.org/releases/pkg-config-0.25.tar.gz
if [ "$(shasum -a 1 pkg-config-0.25.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo pkgconfig checksum mismatch
	exit
fi
tar -zxf pkg-config-0.25.tar.gz
cd pkg-config-0.25
./configure --prefix=${MUMBLE_PREFIX}
make
make install
