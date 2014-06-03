#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source /MumbleBuild/latest-1.2.x/env

ver=$(git describe)

if [ "${MUMBLE_BUILD_TYPE}" == "Release" ]; then
    qmake -spec unsupported/macx-clang -recursive CONFIG+="release static no-client no-dbus" DEFINES+="MUMBLE_VERSION=${ver}" main.pro
else
    qmake -spec unsupported/macx-clang -recursive CONFIG+="release static no-client no-dbus" DEFINES+="MUMBLE_VERSION=${ver} SNAPSHOT_BUILD=1" main.pro
fi

make

cd scripts
bash mkini.sh
cd ..

mkdir -p release/tarball-root
mv release/murmurd release/tarball-root/murmurd
cp installer/gpl.txt release/tarball-root/LICENSE
cp README.static.osx release/tarball-root/README
mkdir -p release/tarball-root/ice/
cp scripts/icedemo.php release/tarball-root/ice/icedemo.php
cp scripts/weblist.php release/tarball-root/ice/weblist.php
cp src/murmur/Murmur.ice release/tarball-root/ice/Murmur.ice
cp scripts/murmur.ini.osx release/tarball-root/murmur.ini

cd release/tarball-root/
chmod +x murmurd
mkdir -p ../tarball
gnutar --owner=root -cjpf ../tarball/Murmur-OSX-Static-${ver}.tar.bz2 *
cd ../..
rm -rf release/tarball-root/
