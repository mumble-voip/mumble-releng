#!/bin/bash -ex
SHA1="3e042e5f2c7223bffdaac9646a533b8c758b65b5"
curl -O "http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.9.tar.gz"
if [ "$(sha1sum ncurses-5.9.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo ncurses checksum mismatch
	exit
fi
tar -zxf ncurses-5.9.tar.gz
cd ncurses-5.9
./configure --prefix=${MUMBLE_PREFIX} --with-shared
make
make install
