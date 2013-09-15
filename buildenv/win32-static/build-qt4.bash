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
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/qt4-static-system-zlib-bootstrap.patch
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/qt4-static-system-zlib.patch

cmd /c configure -release -static -prefix $(cygpath -w ${MUMBLE_PREFIX}/Qt4.8) -qt-sql-sqlite -qt-sql-mysql -I $(cygpath -w ${MUMBLE_PREFIX}/mariadbclient/mariadbclient/include) -L $(cygpath -w ${MUMBLE_PREFIX}/mariadbclient/lib) -no-qt3support -no-exceptions -system-zlib -I $(cygpath -w ${MUMBLE_PREFIX}/zlib/include) -L $(cygpath -w ${MUMBLE_PREFIX}/zlib/lib) -qt-libpng -qt-libjpeg -openssl-linked -I $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/include) -L $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/lib) OPENSSL_LIBS="-llibeay32 -lssleay32 -lcrypt32" -platform win32-msvc2010 -no-dbus -nomake demos -nomake examples -no-webkit -ltcg -mp -opensource -confirm-license
cmd /c nmake
cmd /c nmake install

# Remove bad includes from QtGui that will not allow mumble_app.dll to link.
sed -i -re 's,#include "qs60style.h",,g;
            s,#include "qaccessiblebridge.h",,g;
            s,#include "qwsembedwidget.h",,g;' ${MUMBLE_PREFIX}/Qt4.8/include/QtGui/QtGui
