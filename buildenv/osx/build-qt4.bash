#!/bin/bash
if [ -d mumble-developers-qt ]; then
	cd mumble-developers-qt
	git reset --hard
	git clean -dfx
else
	git clone git://gitorious.org/+mumble-developers/qt/mumble-developers-qt.git
	cd mumble-developers-qt
	git fetch origin 4.8-mumble
	git checkout 3565c7ae57d3a60eff50b7b3182043ca6169338b
fi	
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
export CFLAGS="-I$MUMBLE_PREFIX/include"
export CXXFLAGS="-I$MUMBLE_PREFIX/include"
OPENSSL_LIBS="-L$MUMBLE_PREFIX/lib -lssl -lcrypto" ./configure -platform unsupported/macx-clang -static -no-reduce-exports -no-pch -fast -nomake examples -nomake demos -nomake docs -debug-and-release -arch x86_64 -cocoa -qt-sql-sqlite -no-dbus -no-webkit -no-phonon -no-phonon-backend -no-qt3support -no-multimedia -no-audio-backend -qt-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg -openssl-linked -mysql_config no -sdk ${OSX_SDK} -prefix ${MUMBLE_PREFIX}/Qt4.8 -opensource -confirm-license
make
make install
