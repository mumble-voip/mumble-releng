#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://pkgconfig.freedesktop.org/releases/pkg-config-0.28.tar.gz"
expect_sha1 "pkg-config-0.28.tar.gz" "71853779b12f958777bffcb8ca6d849b4d3bed46"
expect_sha256 "pkg-config-0.28.tar.gz" "6b6eb31c6ec4421174578652c7e141fdaae2dabad1021f420d8713206ac1f845"

tar -zxf pkg-config-0.28.tar.gz
cd pkg-config-0.28

# pkg-config doesn't need to be built as a universal binary.
# it even breaks stuff (stat()'ing .pc files revels they aren't ST_REG)
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

./configure --prefix=${MUMBLE_PREFIX} --with-internal-glib --disable-dependency-tracking
make
make install
