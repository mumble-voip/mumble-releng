#!/bin/bash
SHA1="732a1a54dd9a507f4911602bac45bbe827c3d82d"
curl -L -O "http://download.qt-project.org/development_releases/qt/5.2/5.2.0-beta1/single/qt-everywhere-opensource-src-5.2.0-beta1.tar.gz"
if [ "$(shasum -a 1 qt-everywhere-opensource-src-5.2.0-beta1.tar.gz | cut -b -40)" != "${SHA1}" ]; then
        echo qt5 checksum mismatch
        exit
fi

tar -zxf qt-everywhere-opensource-src-5.2.0-beta1.tar.gz
cd qt-everywhere-opensource-src-5.2.0-beta1

# Disable qmacpasteboardmime. There are symbol clashes with the 'cocoa' plugin,
# so seemingly, these two modules aren't currently engineered to be used in a
# static build together.
patch -p1 < ../patches/qt5-macextras-disable-qmacpasteboardmime.patch

unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
export CFLAGS="-I$MUMBLE_PREFIX/include"
export CXXFLAGS="-I$MUMBLE_PREFIX/include"
OPENSSL_LIBS="-L$MUMBLE_PREFIX/lib -lssl -lcrypto" ./configure -v -platform macx-clang -no-c++11 -process -static -no-reduce-exports -pch -skip qtwebkit -skip qtwebkit-examples -nomake examples -nomake tests -release -qt-sql-sqlite -no-dbus -qt-pcre -qt-zlib -qt-libpng -qt-libjpeg -openssl-linked -mysql_config no -sdk macosx -prefix ${MUMBLE_PREFIX}/Qt5.2 -opensource -confirm-license
make
make install
