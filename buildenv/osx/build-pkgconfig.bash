#!/bin/bash
SHA1="71853779b12f958777bffcb8ca6d849b4d3bed46"
curl -L -O "http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz"
if [ "$(shasum -a 1 pkg-config-0.28.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo pkgconfig checksum mismatch
	exit
fi
tar -zxf pkg-config-0.28.tar.gz
cd pkg-config-0.28
./configure --prefix=${MUMBLE_PREFIX} --with-internal-glib
make
make install
