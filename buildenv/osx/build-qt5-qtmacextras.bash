#!/bin/bash
if [ -d qtmacextras ]; then
	cd qtmacextras
else
	git clone git://gitorious.org/qt/qtmacextras.git
	cd qtmacextras
	git checkout 509edd3e13cddb6f6b22ec014c1af90bb6f5479b
fi	
export PATH=$MUMBLE_PREFIX/Qt5.1/bin:$PATH
qmake
make
make install
