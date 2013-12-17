#!/bin/bash
if [ -d mumble-developers-qt ]; then
	cd mumble-developers-qt
else
	git clone git://gitorious.org/+mumble-developers/qt/mumble-developers-qt.git
	cd mumble-developers-qt
	git branch -t 4.8-mumble origin/4.8-mumble
	git checkout 0a6c959e31635ba779c6a07e4b0d176493afd9c4
fi	
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
export CFLAGS="-I$MUMBLE_PREFIX/include"
export CXXFLAGS="-I$MUMBLE_PREFIX/include"
OPENSSL_LIBS="-Wl,-search_paths_first -L$MUMBLE_PREFIX/lib -lssl -lcrypto" ./configure -static -no-reduce-exports -no-pch -fast -nomake examples -nomake demos -nomake docs -debug-and-release -universal -carbon -qt-sql-sqlite -no-dbus -no-webkit -no-phonon -no-phonon-backend -no-qt3support -no-multimedia -no-audio-backend -qt-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg -openssl-linked -mysql_config no -sdk ${OSX_SDK} -prefix ${MUMBLE_PREFIX}/Qt4.8 -opensource -confirm-license
make
make install
