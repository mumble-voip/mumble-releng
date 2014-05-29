#!/bin/bash -ex
SHA1="8c84d6e3b227f583d05e08251e07047e6c3a6b42"
curl -L -O "http://www.zeroc.com/download/Ice/3.4/Ice-3.4.2.tar.gz"
if [ "$(sha1sum Ice-3.4.2.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo zeroc ice checksum mismatch
	exit
fi
tar -zxf Ice-3.4.2.tar.gz
cd Ice-3.4.2/cpp
patch -p2 < ../../patches/Ice-3.4.2-db5.patch
# embedded_runpath_prefix automatically appends '/lib' to the end of itself.
# that means that $ICE_PREFIX shouldn't be $ICE_PREFIX/lib to be correct.
make prefix=$MUMBLE_ICE_PREFIX embedded_runpath_prefix="$MUMBLE_PREFIX/lib:$MUMBLE_ICE_PREFIX" OPTIMIZE=yes DB_HOME=$MUMBLE_PREFIX MCPP_HOME=$MUMBLE_PREFIX BZIP2_HOME=$MUMBLE_PREFIX EXPAT_HOME=$MUMBLE_PREFIX OPENSSL_HOME=$MUMBLE_PREFIX -j4
make prefix=$MUMBLE_ICE_PREFIX embedded_runpath_prefix="$MUMBLE_PREFIX/lib:$MUMBLE_ICE_PREFIX" OPTIMIZE=yes DB_HOME=$MUMBLE_PREFIX MCPP_HOME=$MUMBLE_PREFIX BZIP2_HOME=$MUMBLE_PREFIX EXPAT_HOME=$MUMBLE_PREFIX OPENSSL_HOME=$MUMBLE_PREFIX install
