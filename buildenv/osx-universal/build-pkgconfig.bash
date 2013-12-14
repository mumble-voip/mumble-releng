#!/bin/bash
SHA1="71853779b12f958777bffcb8ca6d849b4d3bed46"
curl -L -O "http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz"
if [ "$(shasum -a 1 pkg-config-0.28.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo pkgconfig checksum mismatch
	exit
fi
tar -zxf pkg-config-0.28.tar.gz
cd pkg-config-0.28

# pkg-config doesn't need to be built as a universal binary.
# it even breaks stuff (stat()'ing .pc files revels they aren't ST_REG)
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

./configure --prefix=${MUMBLE_PREFIX} --with-internal-glib --disable-dependency-tracking
make
make install
