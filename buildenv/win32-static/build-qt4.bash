#!/bin/bash -ex

source common.bash

if [ -d mumble-developers-qt ]; then
	cd mumble-developers-qt
	git reset --hard
	git clean -dfx
else
	git clone git://gitorious.org/+mumble-developers/qt/mumble-developers-qt.git
	cd mumble-developers-qt
	git branch -t 4.8-mumble origin/4.8-mumble
	git checkout 4.8-mumble
fi

patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/qt4-mariadb-support.patch

cmd /c configure -release -static -prefix $(cygpath -w ${MUMBLE_PREFIX}/Qt4.8) -qt-sql-sqlite -qt-sql-mysql -I $(cygpath -w ${MUMBLE_PREFIX}/mariadbclient/mariadbclient/include) -L $(cygpath -w ${MUMBLE_PREFIX}/mariadbclient/lib) -no-qt3support -no-exceptions -qt-zlib -qt-libpng -qt-libjpeg -openssl-linked -I $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/include) -L $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/lib) OPENSSL_LIBS="-llibeay32 -lssleay32 -lcrypt32" -platform win32-msvc2010 -no-dbus -nomake demos -nomake examples -no-webkit -ltcg -mp -opensource -confirm-license
cmd /c nmake
cmd /c nmake install