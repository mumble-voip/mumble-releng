#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# Utils
./pkgconfig.build
./libtool.build
./autoconf.build
./automake.build
./xz.build

# Mumble
./openssl.build
./libxar.build
./libpng.build
./libjpeg-turbo.build
./qt4.build
./qt4-icnsicon.build
./boost.build
./libogg.build
./libvorbis.build
./libflac.build
./libsndfile.build
./protobuf.build

# Murmur
./berkeleydb.build
./libmcpp.build
./zeroc-ice.build
