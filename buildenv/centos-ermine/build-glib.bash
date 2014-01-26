#!/bin/bash
set -e
SHA1="685c5a4215b776b83dd5330ab9084c5dcb0a51b8"
curl -O "ftp://ftp.gnome.org/pub/gnome/sources/glib/2.38/glib-2.38.2.tar.xz"
if [ "$(sha1sum glib-2.38.2.tar.xz | cut -b -40)" != "${SHA1}" ]; then
	echo glib checksum mismatch
	exit
fi
xzcat glib-2.38.2.tar.xz | tar -xf -
cd glib-2.38.2
export CFLAGS="-march=i486"
./configure --prefix=$MUMBLE_PREFIX
make
make install
