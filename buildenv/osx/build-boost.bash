#!/bin/bash
SHA1="e6dd1b62ceed0a51add3dda6f3fc3ce0f636a7f3"
curl -L -O "http://downloads.sourceforge.net/project/boost/boost/1.53.0/boost_1_53_0.tar.bz2"
if [ "$(shasum -a 1 boost_1_53_0.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo boost checksum mismatch
	exit
fi
tar -jxf boost_1_53_0.tar.bz2
rm -rf $MUMBLE_PREFIX/include/boost_1_53_0
cd boost_1_53_0
patch -p1 < ../patches/boost-1.48.0-nil-fix.patch
cd ..
mv boost_1_53_0 $MUMBLE_PREFIX/include/
