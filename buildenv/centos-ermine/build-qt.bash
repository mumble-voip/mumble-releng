#!/bin/bash
if [ -d mumble-developers-qt ]; then
	cd mumble-developers-qt
else
	git clone git://gitorious.org/+mumble-developers/qt/mumble-developers-qt.git
	cd mumble-developers-qt
	git branch -t 4.8-mumble origin/4.8-mumble
	git checkout 4.8-mumble
fi	
export OPENSSL_LIBS="-L${MUMBLE_PREFIX}/lib -lssl -lcrypto"
./configure -v -fast -no-gui -nomake examples -nomake demos -nomake docs -release -rpath -glib -plugin-sql-sqlite -plugin-sql-mysql -dbus-linked -no-webkit -no-script -no-scripttools -no-phonon -no-phonon-backend -no-qt3support -no-multimedia -no-audio-backend -system-zlib -qt-libtiff -qt-libpng -qt-libmng -qt-libjpeg -openssl-linked -I${MUMBLE_PREFIX}/include -L${MUMBLE_PREFIX}/lib -R${MUMBLE_PREFIX}/lib -mysql_config ${MUMBLE_PREFIX}/bin/mysql_config -prefix ${MUMBLE_QT_PREFIX} -opensource -confirm-license
make -j4
make install
