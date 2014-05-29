#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash

rm -rf xar.git
git clone https://github.com/mkrautz/xar xar.git
cd xar.git/xar
export CFLAGS="-I${OSX_SDK}/usr/include/libxml2 ${CFLAGS} -I${MUMBLE_PREFIX}/include/"
export LDFLAGS="${LDFLAGS} -L${MUMBLE_PREFIX}/lib/"
./autogen.sh --prefix=${MUMBLE_PREFIX} --disable-shared --enable-static --without-lzma
make
make install
