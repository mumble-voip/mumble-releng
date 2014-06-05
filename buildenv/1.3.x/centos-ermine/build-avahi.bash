#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "https://distfiles.macports.org/avahi/avahi-0.6.31.tar.gz" # unofficial; avahi.org down for several days.
expect_sha1 "avahi-0.6.31.tar.gz" "7e05bd78572c9088b03b1207a0ad5aba38490684"
expect_sha256 "avahi-0.6.31.tar.gz" "8372719b24e2dd75de6f59bb1315e600db4fd092805bd1201ed0cb651a2dab48"

tar -zxf avahi-0.6.31.tar.gz
cd avahi-0.6.31
CFLAGS="-L${MUMBLE_PREFIX}/lib -I${MUMBLE_PREFIX}/include" ./configure --prefix=${MUMBLE_PREFIX} --enable-compat-libdns_sd --disable-qt3 --disable-qt4 --disable-gtk --disable-gtk3 --enable-dbus --with-xml=expat --disable-gdbm --disable-dbm --enable-libdaemon --disable-python --disable-python-dbus --disable-mono --disable-monodoc
make
make install
