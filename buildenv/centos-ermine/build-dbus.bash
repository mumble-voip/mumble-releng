#!/bin/bash
set -e
SHA1="d14ab33e92e29fa732cdff69214913832181e737"
curl -O "http://dbus.freedesktop.org/releases/dbus/dbus-1.8.0.tar.gz"
if [ "$(sha1sum dbus-1.8.0.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo dbus checksum mismatch
	exit
fi
tar -zxf dbus-1.8.0.tar.gz
cd dbus-1.8.0
CFLAGS="-L${MUMBLE_PREFIX}/lib -I${MUMBLE_PREFIX}/include" ./configure --prefix=$MUMBLE_PREFIX --with-xml=expat --with-system-socket=/var/run/dbus/system_bus_socket
make
make install
