#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

./cmake.build
./zlib.build
./bzip2.build
./openssl.build
./expat.build
./python.build
./libffi.build
./glib.build
./dbus.build
./libdaemon.build
./avahi.build
./ncurses.build
./mysql.build
./protobuf.build
./boost.build
./qt4.build
./libmcpp.build
./berkeleydb.build
./zeroc-ice.build
./libcap.build

if [ -n "${MUMBLE_BUILD_FETCHMODE}" ]; then
	exit 0
fi

./extract-dbg.bash
./setup-ermine-env.bash
