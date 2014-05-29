#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# Utils
./build-pkgconfig.bash
./build-libtool.bash
./build-autoconf.bash
./build-automake.bash

# Mumble
./build-openssl.bash
./build-libxar.bash
./build-qt4.bash
./build-qt4-icnsicon.bash
./build-boost.bash
./build-libogg.bash
./build-libvorbis.bash
./build-libflac.bash
./build-libsndfile.bash
./build-protobuf.bash
./build-portaudio.bash
