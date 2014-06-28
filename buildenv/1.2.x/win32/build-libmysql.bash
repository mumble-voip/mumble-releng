#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.19.zip"
expect_sha1 "mysql-5.6.19.zip" "df34b5ccb7f51b668041662e5f2ec381565ae351"
expect_sha256 "mysql-5.6.19.zip" "ccc3183f2bbeef6e15ec60623bdee29037d2d2e717327267bf1add74944881c6"

unzip -q mysql-5.6.19.zip
cd mysql-5.6.19

mkdir -p __build__
cd __build__
cmd /c $(cygpath -w ${MUMBLE_PREFIX}/cmake/bin/cmake.exe) -G "Visual Studio 10" ..
cmd /c msbuild MySQL.sln /p:Configuration=RelWithDebInfo

mkdir -p ${MUMBLE_PREFIX}/MySQL
mkdir -p ${MUMBLE_PREFIX}/MySQL/lib

cp libmysql/RelWithDebInfo/*{.lib,.dll,pdb} ${MUMBLE_PREFIX}/MySQL/lib/
cp -R ../include ${MUMBLE_PREFIX}/MySQL/include
cp include/*.h ${MUMBLE_PREFIX}/MySQL/include/
