#!/bin/bash
set -e
SHA1="842c4e2aff3f016feea3c6e992c7fa96e49c9aa0"
curl -O "http://python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2"
if [ "$(sha1sum Python-2.7.3.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo python checksum mismatch
	exit
fi
tar -jxf Python-2.7.3.tar.bz2
cd Python-2.7.3
./configure --prefix=$MUMBLE_PREFIX
make
make install
