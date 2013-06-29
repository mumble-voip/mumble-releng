#!/bin/bash
if [ -d qt-icns-iconengine-qt5 ]; then
	cd qt-icns-iconengine-qt5
else
	git clone git://github.com/mkrautz/qt-icns-iconengine.git qt-icns-iconengine-qt5
	cd qt-icns-iconengine-qt5
	git checkout qt5
fi	
qmake
make