#!/bin/bash
SHA1="703356b7c2cd30d7fb6000625bf3ccc2eb977ecb"
curl -L -O "http://downloads.sourceforge.net/project/mcpp/mcpp/V.2.7.2/mcpp-2.7.2.tar.gz"
if [ "$(shasum -a 1 mcpp-2.7.2.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libmcpp checksum mismatch
	exit
fi
tar -zxf mcpp-2.7.2.tar.gz
cd mcpp-2.7.2
patch -p1  < ../patches/zeroc-patch.mcpp.2.7.2
cd src
patch --binary -p0 < ../noconfig/vc2010.dif
cmd /c nmake MCPP_LIB=1 /f ..\\noconfig\\visualc.mak mcpplib_lib
mkdir -p ${MUMBLE_PREFIX}/mcpp/
cp mcpp.lib ${MUMBLE_PREFIX}/mcpp/