#!/bin/bash -ex
if [ -d mumble-developers-qt ]; then
	cd mumble-developers-qt
else
	git clone https://github.com/mumble-voip/mumble-developers-qt.git
	cd mumble-developers-qt
	git branch -t 4.8-mumble origin/4.8-mumble
	git checkout 2147fa767980fe27a14f018b1528dbf880b96814
fi	
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
export CFLAGS="-I$MUMBLE_PREFIX/include"
export CXXFLAGS="-I$MUMBLE_PREFIX/include"
OPENSSL_LIBS="-Wl,-search_paths_first -L$MUMBLE_PREFIX/lib -lssl -lcrypto" ./configure -static -no-reduce-exports -no-pch -fast -nomake examples -nomake demos -nomake docs -debug-and-release -universal -carbon -qt-sql-sqlite -no-dbus -no-webkit -no-phonon -no-phonon-backend -no-qt3support -no-multimedia -no-audio-backend -qt-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg -openssl-linked -mysql_config no -sdk ${OSX_SDK} -prefix ${MUMBLE_PREFIX}/Qt4.8 -opensource -confirm-license
make
make install
