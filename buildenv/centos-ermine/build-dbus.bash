#!/bin/bash
set -e
SHA1="d9634807d1de9b64727ae2178e3af2227fca0fca"
curl -O "http://dbus.freedesktop.org/releases/dbus/dbus-1.6.8.tar.gz"
if [ "$(sha1sum dbus-1.6.8.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo dbus checksum mismatch
	exit
fi
tar -zxf dbus-1.6.8.tar.gz
cd dbus-1.6.8
CFLAGS="-L${MUMBLE_PREFIX}/lib -I${MUMBLE_PREFIX}/include" ./configure --prefix=$MUMBLE_PREFIX --with-xml=expat --with-system-socket=/var/run/dbus/system_bus_socket
make
make install
