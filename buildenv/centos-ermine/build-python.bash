#!/bin/bash
set -e
SHA1="8328d9f1d55574a287df384f4931a3942f03da64"
curl -O "http://python.org/ftp/python/2.7.6/Python-2.7.6.tgz"
if [ "$(sha1sum Python-2.7.6.tgz | cut -b -40)" != "${SHA1}" ]; then
	echo python checksum mismatch
	exit
fi
tar -zxf Python-2.7.6.tgz
cd Python-2.7.6
./configure --prefix=$MUMBLE_PREFIX
make
make install
