#!/bin/bash -ex
SHA1="f5230890dc0be42fb5c58fbf793da253155de106"
curl -O "http://ftp.gwdg.de/pub/linux/sources.redhat.com/libffi/libffi-3.0.13.tar.gz"
if [ "$(sha1sum libffi-3.0.13.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo libffi checksum mismatch
	exit
fi
tar -zxf libffi-3.0.13.tar.gz
cd libffi-3.0.13
./configure --prefix=$MUMBLE_PREFIX
make
make install
