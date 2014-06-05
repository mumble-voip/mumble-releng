#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.openssl.org/source/openssl-1.0.0m.tar.gz"
expect_sha1 "openssl-1.0.0m.tar.gz" "039041fd00f45a0f485ca74f85209b4101a43a0f"
expect_sha256 "openssl-1.0.0m.tar.gz" "224dbbfaee3ad7337665e24eab516c67446d5081379a40b2f623cf7801e672de"

tar -zxf openssl-1.0.0m.tar.gz
cd openssl-1.0.0m
./Configure linux-elf shared zlib threads --prefix=${MUMBLE_PREFIX} --openssldir=${MUMBLE_PREFIX}/openssl -L${MUMBLE_PREFIX}/lib -I${MUMBLE_PREFIX}/include
make
make install
