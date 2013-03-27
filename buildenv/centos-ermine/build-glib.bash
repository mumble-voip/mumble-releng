#!/bin/bash
set -e
SHA1="f2b94ca757191dddba686e54b32b3dfc5ad5d8fb"
curl -O "http://ftp.gnome.org/pub/GNOME/sources/glib/2.34/glib-2.34.3.tar.xz"
if [ "$(sha1sum glib-2.34.3.tar.xz | cut -b -40)" != "${SHA1}" ]; then
	echo glib checksum mismatch
	exit
fi
xzcat glib-2.34.3.tar.xz | tar -xf -
cd glib-2.34.3
./configure --prefix=$MUMBLE_PREFIX
make
make install
