#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://ftpmirror.gnu.org/libtool/libtool-2.4.2.tar.gz"
expect_sha1 "libtool-2.4.2.tar.gz" "22b71a8b5ce3ad86e1094e7285981cae10e6ff88"
expect_sha256 "libtool-2.4.2.tar.gz" "b38de44862a987293cd3d8dfae1c409d514b6c4e794ebc93648febf9afc38918"

tar -zxf libtool-2.4.2.tar.gz
cd libtool-2.4.2
./configure --prefix=${MUMBLE_PREFIX} --program-prefix=g --enable-ltdl-install
make
make install
