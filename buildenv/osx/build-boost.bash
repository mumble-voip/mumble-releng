#!/bin/bash
SHA1="52ef06895b97cc9981b8abf1997c375ca79f30c5"
curl -L -O "http://downloads.sourceforge.net/project/boost/boost/1.51.0/boost_1_51_0.tar.bz2"
if [ "$(shasum -a 1 boost_1_51_0.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo boost checksum mismatch
	exit
fi
tar -jxf boost_1_51_0.tar.bz2
rm -rf $MUMBLE_PREFIX/include/boost_1_51_0
cd boost_1_51_0
patch -p1 < ../patches/boost-1.48.0-nil-fix.patch
cd ..
mv boost_1_51_0 $MUMBLE_PREFIX/include/
