#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://download.qt-project.org/development_releases/qt/5.2/5.2.0-beta1/single/qt-everywhere-opensource-src-5.2.0-beta1.zip"
expect_sha1 "qt-everywhere-opensource-src-5.2.0-beta1.zip" "2059a73d7d4bcc6f4744d9731687d39b894f3b6e"

unzip -q -o qt-everywhere-opensource-src-5.2.0-beta1.zip
cd qt-everywhere-opensource-src-5.2.0-beta1

chmod +x qtbase/configure.exe
chmod +x gnuwin32/bin/*

patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/qt5-mariadb-support.patch
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/qt5-qsvg-system-zlib-support.patch
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/qt5-qtimageformats-system-zlib-support.patch

cmd /c configure -release -static -no-c++11 -skip qtwebkit -skip qtwebkit-examples -prefix $(cygpath -w ${MUMBLE_PREFIX}/Qt5.2) -qt-sql-sqlite -qt-sql-mysql -I $(cygpath -w ${MUMBLE_PREFIX}/mariadbclient/mariadbclient/include) -L $(cygpath -w ${MUMBLE_PREFIX}/mariadbclient/lib) -system-zlib -I $(cygpath -w ${MUMBLE_PREFIX}/zlib/include) -L $(cygpath -w ${MUMBLE_PREFIX}/zlib/lib) ZLIB_LIBS="-lzlib" -qt-libpng -qt-libjpeg -openssl-linked -I $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/include) -L $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/lib) OPENSSL_LIBS="-llibeay32 -lssleay32 -lcrypt32 -lgdi32" -platform win32-msvc2010 -no-dbus -nomake examples -nomake tests -ltcg -mp -opensource -confirm-license
cmd /c nmake
cmd /c nmake install
