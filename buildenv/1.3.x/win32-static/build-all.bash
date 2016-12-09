#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# Binary tools
./nasm.build
./cmake.build
./jom.build
./python.build
./perl.build

./boost.build
./openssl.build
./protobuf.build

./libogg.build
./libvorbis.build
./libflac.build
./libsndfile.build

./bonjour.build

./zlib.build

./libpng.build
./libjpeg-turbo.build

./sqlite3.build
./mariadb-client.build

./freetype.build
./harfbuzz-ng.build

./pcre.build

./qt5.build

./libmcpp.build
./bzip2.build
./berkeleydb.build
./expat.build
./zeroc-ice.build

./asio.build
./g15sdk.build
