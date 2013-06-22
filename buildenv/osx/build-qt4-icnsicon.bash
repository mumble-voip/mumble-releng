#!/bin/bash
if [ -d qt-icns-iconengine ]; then
	cd qt-icns-iconengine
else
	git clone git://github.com/mkrautz/qt-icns-iconengine.git
	cd qt-icns-iconengine
fi	
qmake -spec unsupported/macx-clang CONFIG+='release static'
make
cp libqicnsicon.a $MUMBLE_PREFIX/Qt4.8/plugins/iconengines/libqicnsicon.a
make distclean
qmake -spec unsupported/macx-clang CONFIG+='debug static'
make
cp libqicnsicon.a $MUMBLE_PREFIX/Qt4.8/plugins/iconengines/libqicnsicon_debug.a
make distclean
