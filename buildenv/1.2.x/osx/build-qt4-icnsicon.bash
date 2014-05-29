#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash

if [ -d qt-icns-iconengine ]; then
	cd qt-icns-iconengine
else
	git clone git://github.com/mkrautz/qt-icns-iconengine.git
	cd qt-icns-iconengine
fi

${MUMBLE_PREFIX}/Qt4.8/bin/qmake -spec unsupported/macx-clang CONFIG+='release static'
make
cp libqicnsicon.a ${MUMBLE_PREFIX}/Qt4.8/plugins/iconengines/libqicnsicon.a
make distclean

${MUMBLE_PREFIX}/Qt4.8/bin/qmake -spec unsupported/macx-clang CONFIG+='debug static'
make
cp libqicnsicon.a ${MUMBLE_PREFIX}/Qt4.8/plugins/iconengines/libqicnsicon_debug.a
make distclean
