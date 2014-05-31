#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://dbus.freedesktop.org/releases/dbus/dbus-1.8.0.tar.gz"
expect_sha1 "dbus-1.8.0.tar.gz" "d14ab33e92e29fa732cdff69214913832181e737"
expect_sha256 "dbus-1.8.0.tar.gz" "769f8c7282b535ccbe610f63a5f14137a5549834b0b0c8a783e90891b8d70b13"

tar -zxf dbus-1.8.0.tar.gz
cd dbus-1.8.0
CFLAGS="-L${MUMBLE_PREFIX}/lib -I${MUMBLE_PREFIX}/include" ./configure --prefix=${MUMBLE_PREFIX} --disable-selinux --with-xml=expat --with-system-socket=/var/run/dbus/system_bus_socket
make
make install
