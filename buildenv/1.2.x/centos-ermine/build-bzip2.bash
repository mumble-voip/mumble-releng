#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
expect_sha1 "bzip2-1.0.6.tar.gz" "3f89f861209ce81a6bab1fd1998c0ef311712002"
expect_sha256 "bzip2-1.0.6.tar.gz" "a2848f34fcd5d6cf47def00461fcb528a0484d8edef8208d6d2e2909dc61d9cd"

tar -zxf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
make
make PREFIX=${MUMBLE_PREFIX} install
make clean
make -f Makefile-libbz2_so
cp libbz2.so.1.0.6 ${MUMBLE_PREFIX}/lib/
cd ${MUMBLE_PREFIX}/lib/
ln -sf libbz2.so.1.0.6 libbz2.so.1.0
ln -sf libbz2.so.1.0.6 libbz2.so.1
ln -sf libbz2.so.1.0.6 libbz2.so
