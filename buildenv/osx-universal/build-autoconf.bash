#!/bin/bash
SHA1="562471cbcb0dd0fa42a76665acf0dbb68479b78a"
curl -L -O "http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz"
if [ "$(shasum -a 1 autoconf-2.69.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libtool checksum mismatch
	exit
fi
tar -zxf autoconf-2.69.tar.gz
cd autoconf-2.69
sed -i '' -e 's,libtoolize,glibtoolize,g' bin/autoreconf.in
./configure --prefix=${MUMBLE_PREFIX} --disable-dependency-tracking
make
make install
