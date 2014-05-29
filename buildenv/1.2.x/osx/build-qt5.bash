#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://download.qt-project.org/development_releases/qt/5.2/5.2.0-beta1/single/qt-everywhere-opensource-src-5.2.0-beta1.tar.gz"
expect_sha1 "qt-everywhere-opensource-src-5.2.0-beta1.tar.gz" "732a1a54dd9a507f4911602bac45bbe827c3d82d"
expect_sha256 "qt-everywhere-opensource-src-5.2.0-beta1.tar.gz" "bb931c1e09d8f42b08b504d3da8d9ecc1684ebb16e983bd2f0076133085200aa"

tar -zxf qt-everywhere-opensource-src-5.2.0-beta1.tar.gz
cd qt-everywhere-opensource-src-5.2.0-beta1

# Disable qmacpasteboardmime. There are symbol clashes with the 'cocoa' plugin,
# so seemingly, these two modules aren't currently engineered to be used in a
# static build together.
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/qt5-macextras-disable-qmacpasteboardmime.patch

unset CFLAGS
unset CXXFLAGS
unset LDFLAGS

export CFLAGS="-I${MUMBLE_PREFIX}/include"
export CXXFLAGS="-I${MUMBLE_PREFIX}/include"

OPENSSL_LIBS="-L${MUMBLE_PREFIX}/lib -lssl -lcrypto" ./configure -v -platform macx-clang -no-c++11 -process -static -no-reduce-exports -pch -skip qtwebkit -skip qtwebkit-examples -nomake examples -nomake tests -release -qt-sql-sqlite -no-dbus -qt-pcre -qt-zlib -qt-libpng -qt-libjpeg -openssl-linked -mysql_config no -sdk macosx -prefix ${MUMBLE_PREFIX}/Qt5.2 -opensource -confirm-license

make
make install
