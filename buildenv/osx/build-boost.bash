#!/bin/bash
SHA1="230782c7219882d0fab5f1effbe86edb85238bf4"
curl -L -O "http://downloads.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.tar.bz2"
if [ "$(shasum -a 1 boost_1_54_0.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo boost checksum mismatch
	exit
fi
tar -jxf boost_1_54_0.tar.bz2
rm -rf $MUMBLE_PREFIX/include/boost_1_54_0
cd boost_1_54_0
patch -p1 < ../patches/boost-1.48.0-nil-fix.patch
cd ..
mv boost_1_54_0 $MUMBLE_PREFIX/include/
