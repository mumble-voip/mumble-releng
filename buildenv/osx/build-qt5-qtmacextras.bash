#!/bin/bash
if [ -d qtmacextras ]; then
	cd qtmacextras
else
	git clone git://gitorious.org/qt/qtmacextras.git
	cd qtmacextras
	git checkout 509edd3e13cddb6f6b22ec014c1af90bb6f5479b
fi	
qmake
make
make install