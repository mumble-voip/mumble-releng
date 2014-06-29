#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
expect_sha1 "bzip2-1.0.6.tar.gz" "3f89f861209ce81a6bab1fd1998c0ef311712002"

tar -zxf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/bzip2-linker-pdb.patch
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/bzip2-dll+pdb.patch
cmd /c nmake /f makefile.msc bzip2.dll

mkdir -p ${MUMBLE_PREFIX}/bzip2/{include,lib}
cp libbz2.lib ${MUMBLE_PREFIX}/bzip2/lib/
cp bzip2.dll ${MUMBLE_PREFIX}/bzip2/lib/
cp bzip2.pdb ${MUMBLE_PREFIX}/bzip2/lib/
cp bzlib.h ${MUMBLE_PREFIX}/bzip2/include/