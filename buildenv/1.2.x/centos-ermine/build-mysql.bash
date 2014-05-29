#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.17.tar.gz"
expect_sha1 "mysql-5.6.17.tar.gz" "53773d619d7f7bc1743f92fd65885a0581c37ff8"
expect_sha256 "mysql-5.6.17.tar.gz" "f8ed0a1abd60ed9152b71a027446825d8686c48e99def6e74e0d12d24e9a1d9b"

tar -zxf mysql-5.6.17.tar.gz
cd mysql-5.6.17
cmake -DCMAKE_INSTALL_PREFIX=${MUMBLE_PREFIX} -DINSTALL_LAYOUT=RPM -DWITH_EMBEDDED_SERVER=OFF -DWITH_SERVER=OFF -DWITH_SSL=yes -DWITH_LIBEDIT=yes -DWITH_ZLIB=system -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
make -j4
make install
