#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://mirrors.linsrv.net/mariadb/mariadb-native-client/Source/mariadb-native-client.tar.gz"
expect_sha1 "mariadb-native-client.tar.gz" "2255a1e70917fe77b4ab8a039df9f9879d6e14e9"

tar -zxf mariadb-native-client.tar.gz
cd mariadb-native-client

# Avoid resetting the CMAKE_INSTALL_PREFIX to empty string
# on Windows.
sed -i -e 's, SET(CMAKE_INSTALL_PREFIX ""),,g' CMakeLists.txt

# Our static OpenSSL has the e_capi (CryptoAPI) engine
# linked in. This adds a depedency on crypt32.lib.
# We seemingly can't easily disable the .DLL from building,
# so we'll just add crypt32.lib as a dependant library. 
sed -i -e 's,ws2_32,ws2_32 crypt32,g' libmysql/CMakeLists.txt

cmd /c $(cygpath -w ${MUMBLE_PREFIX}/cmake/bin/cmake.exe) -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_INSTALL_PREFIX=$(cygpath -w ${MUMBLE_PREFIX}/mariadbclient) -DZLIB_ROOT=$(cygpath -w ${MUMBLE_PREFIX}/zlib) -DOPENSSL_ROOT_DIR=$(cygpath -w ${MUMBLE_PREFIX}/OpenSSL)
cmd /c nmake
cmd /c nmake install

# Remove libmariadb .dll and .lib. We don't need/want them in our static build.
rm -rf ${MUMBLE_PREFIX}/mariadbclient/lib/libmariadb.*

# Qt, our only user, expects to link against libmysqlclient.
# Rename our static library so we don't disappoint Qt.
mv ${MUMBLE_PREFIX}/mariadbclient/lib/mariadbclient.lib ${MUMBLE_PREFIX}/mariadbclient/lib/libmysql.lib