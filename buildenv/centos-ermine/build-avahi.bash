#!/bin/bash -ex
SHA1="7e05bd78572c9088b03b1207a0ad5aba38490684"
curl -O "http://avahi.org/download/avahi-0.6.31.tar.gz" 
if [ "$(sha1sum avahi-0.6.31.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo avahi checksum mismatch
	exit
fi
tar -zxf avahi-0.6.31.tar.gz
cd avahi-0.6.31
CFLAGS="-L${MUMBLE_PREFIX}/lib -I${MUMBLE_PREFIX}/include" ./configure --prefix=${MUMBLE_PREFIX} --enable-compat-libdns_sd --disable-qt3 --disable-qt4 --disable-gtk --disable-gtk3 --enable-dbus --with-xml=expat --disable-gdbm --disable-dbm --enable-libdaemon --disable-python --disable-python-dbus --disable-mono --disable-monodoc
make
make install
