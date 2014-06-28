#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash

if [ -d mumble-developers-qt ]; then
	cd mumble-developers-qt
	git reset --hard
	git clean -dfx
else
	git clone https://github.com/mumble-voip/mumble-developers-qt.git
	cd mumble-developers-qt
	git fetch origin 4.8-mumble
	git checkout 2147fa767980fe27a14f018b1528dbf880b96814
fi

cmd /c configure.exe -debug-and-release -prefix $(cygpath -w ${MUMBLE_PREFIX}/Qt4.8) -qt-sql-sqlite -qt-sql-mysql -no-qt3support -no-exceptions -qt-zlib -qt-libpng -qt-libjpeg -openssl -I $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/include) -L $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/lib) OPENSSL_LIBS="-lssleay32 -llibeay32" -I $(cygpath -w ${MUMBLE_PREFIX}/MySQL/include) -L $(cygpath -w ${MUMBLE_PREFIX}/MySQL/lib) -platform win32-msvc2010 -no-dbus -nomake demos -nomake examples -no-webkit -ltcg -mp -opensource -confirm-license
cmd /c nmake
cmd /c nmake install