#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.zeroc.com/download/Ice/3.4/Ice-3.4.2.tar.gz"
expect_sha1 "Ice-3.4.2.tar.gz" "8c84d6e3b227f583d05e08251e07047e6c3a6b42"
expect_sha256 "Ice-3.4.2.tar.gz" "dcf0484495b6df0849ec90a00e8204fe5fe1c0d3882bb438bf2c1d062f15c979"

tar -zxf Ice-3.4.2.tar.gz
cd Ice-3.4.2/cpp
patch -p2 < ${MUMBLE_BUILDENV_ROOT}/patches/Ice-3.4.2-db5.patch
# embedded_runpath_prefix automatically appends '/lib' to the end of itself.
# that means that $ICE_PREFIX shouldn't be $ICE_PREFIX/lib to be correct.
make prefix="${MUMBLE_ICE_PREFIX}" embedded_runpath_prefix="${MUMBLE_PREFIX}/lib:${MUMBLE_ICE_PREFIX}" OPTIMIZE=yes DB_HOME="${MUMBLE_PREFIX}" MCPP_HOME="${MUMBLE_PREFIX}" BZIP2_HOME="${MUMBLE_PREFIX}" EXPAT_HOME="${MUMBLE_PREFIX}" OPENSSL_HOME="${MUMBLE_PREFIX}" -j4
make prefix="${MUMBLE_ICE_PREFIX}" embedded_runpath_prefix="${MUMBLE_PREFIX}/lib:${MUMBLE_ICE_PREFIX}" OPTIMIZE=yes DB_HOME="${MUMBLE_PREFIX}" MCPP_HOME="${MUMBLE_PREFIX}" BZIP2_HOME="${MUMBLE_PREFIX}" EXPAT_HOME="${MUMBLE_PREFIX}" OPENSSL_HOME="${MUMBLE_PREFIX}" install
