#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://download.oracle.com/berkeley-db/db-5.3.28.tar.gz"
expect_sha1 "db-5.3.28.tar.gz" "fa3f8a41ad5101f43d08bc0efb6241c9b6fc1ae9"
expect_sha256 "db-5.3.28.tar.gz" "e0a992d740709892e81f9d93f06daf305cf73fb81b545afe72478043172c3628"

tar -zxf db-5.3.28.tar.gz
cd db-5.3.28/build_windows
cmd /c msbuild.exe Berkeley_DB_vs2010.sln /p:Configuration="Release" /p:PlatformToolset=${MUMBLE_VSTOOLSET} /target:db
mkdir -p ${MUMBLE_PREFIX}/berkeleydb/{lib,include}
cp Win32/Release/libdb53.{lib,dll,pdb} ${MUMBLE_PREFIX}/berkeleydb/lib/
cp *.h ${MUMBLE_PREFIX}/berkeleydb/include/