#!/bin/bash
if [ -d mumble-developers-qt ]; then
	cd mumble-developers-qt
else
	git clone git://gitorious.org/+mumble-developers/qt/mumble-developers-qt.git
	cd mumble-developers-qt
	git branch -t 4.8-mumble origin/4.8-mumble
	git checkout 4.8-mumble
fi	

cmd /c configure -release -static -prefix $(cygpath -w ${MUMBLE_PREFIX}/Qt4.8) -qt-sql-sqlite -no-sql-mysql -no-qt3support -no-exceptions -qt-zlib -qt-libpng -qt-libjpeg -openssl-linked -I $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/include) -L $(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/lib) OPENSSL_LIBS="-llibeay32 -lssleay32 -lcrypt32" -platform win32-msvc2010 -no-dbus -nomake demos -nomake examples -no-webkit -ltcg -mp -opensource -confirm-license
cmd /c nmake
cmd /c nmake install