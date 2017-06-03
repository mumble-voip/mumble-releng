#!/bin/bash -ex
# Copyright 2017 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source /MumbleBuild/latest-1.3.x/env
ver=$(python /MumbleBuild/latest-1.3.x/mumble-releng/tools/mumble-version.py)

if [ "${MUMBLE_BUILD_TYPE}" == "Release" ]; then
    qmake -recursive main.pro CONFIG+="release no-client ermine" DEFINES+="MUMBLE_VERSION=${ver}"
else
    qmake -recursive main.pro CONFIG+="release no-client ermine" DEFINES+="MUMBLE_VERSION=${ver} SNAPSHOT_BUILD=1"
fi

make

cd scripts
bash mkini.sh
cd ..

cd release
mkdir -p symbols
mkdir -p tarball-root
mkdir -p appimage
objcopy --only-keep-debug murmurd symbols/murmurd.dbg
objcopy --strip-debug murmurd
cp murmurd appimage/murmurd
cd appimage
LD_LIBRARY_PATH=$MUMBLE_PREFIX/lib:$MUMBLE_ICE_PREFIX/lib linuxdeployqt murmurd -verbose=3
cd ..
mksquashfs appimage/ murmur.squash -all-root
cat $MUMBLE_PREFIX/libexec/appimage/runtime murmur.squash > murmurd.AppImage
cp murmurd.AppImage tarball-root/murmurd.AppImage
cd ..

cp installer/gpl.txt release/tarball-root/LICENSE
cp README.static.linux release/tarball-root/README

mkdir -p release/tarball-root/dbus/
cp scripts/server/dbus/murmur.pl release/tarball-root/murmur.pl
cp scripts/server/dbus/weblist.pl release/tarball-root/weblist.pl

mkdir -p release/tarball-root/ice/
cp scripts/server/ice/icedemo.php release/tarball-root/ice/icedemo.php
cp scripts/server/ice/weblist.php release/tarball-root/ice/weblist.php
cp src/murmur/Murmur.ice release/tarball-root/ice/Murmur.ice

cp scripts/murmur.ini release/tarball-root/murmur.ini

cd release/
mv tarball-root murmur-linux-appimage-i386-${ver}
mkdir -p tarball
chmod +x murmur-linux-appimage-i386-${ver}/murmurd.AppImage
tar --owner=root -cjpf tarball/murmur-linux-appimage-i386-${ver}.tar.bz2 murmur-linux-appimage-i386-${ver}
rm -rf murmur-linux-appimage-i386-${ver}
