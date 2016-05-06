#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

./pkgconfig.build
./libtool.build
./autoconf.build
./automake.build
./xz.build

./boost.build
./openssl.build
./protobuf.build
./libxar.build
./portaudio.build

./libogg.build
./libvorbis.build
./libflac.build
./libsndfile.build

./qt4.build
./qt4-icnsicon.build
