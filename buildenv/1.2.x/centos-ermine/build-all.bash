#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

./build-zlib.bash
./build-bzip2.bash
./build-openssl.bash
./build-expat.bash
./build-python.bash
./build-libffi.bash
./build-glib.bash
./build-dbus.bash
./build-libdaemon.bash
./build-avahi.bash
./build-ncurses.bash
./build-mysql.bash
./build-protobuf.bash
./build-boost.bash
./build-qt4.bash
./build-libmcpp.bash
./build-berkeleydb.bash
./build-zeroc-ice.bash
./build-libcap.bash
./extract-dbg.bash
./setup-ermine-env.bash
