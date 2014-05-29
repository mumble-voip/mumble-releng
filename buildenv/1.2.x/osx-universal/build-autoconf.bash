#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://ftpmirror.gnu.org/autoconf/autoconf-2.69.tar.gz"
expect_sha1 "autoconf-2.69.tar.gz" "562471cbcb0dd0fa42a76665acf0dbb68479b78a"
expect_sha256 "autoconf-2.69.tar.gz" "954bd69b391edc12d6a4a51a2dd1476543da5c6bbf05a95b59dc0dd6fd4c2969"

tar -zxf autoconf-2.69.tar.gz
cd autoconf-2.69
sed -i '' -e 's,libtoolize,glibtoolize,g' bin/autoreconf.in
./configure --prefix=${MUMBLE_PREFIX} --disable-dependency-tracking
make
make install
