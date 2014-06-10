#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source /MumbleBuild/latest-1.2.x/env
ver=$(python /MumbleBuild/latest-1.2.x/mumble-releng/tools/mumble-version.py)
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
objcopy --only-keep-debug murmurd symbols/murmurd.dbg
objcopy --strip-debug murmurd
${HOME}/.ermine/ErminePro.i386 murmurd --verbose --config=${MUMBLE_PREFIX}/etc/ermine.conf --with-gconv=internal --with-locale=noentry --with-xlocale=noentry --kernel-version --output=tarball-root/murmur.x86
zero-ermine-ld.py tarball-root/murmur.x86
cd ..

cp installer/gpl.txt release/tarball-root/LICENSE
cp README.static.linux release/tarball-root/README

mkdir -p release/tarball-root/dbus/
cp scripts/murmur.pl release/tarball-root/dbus/murmur.pl
cp scripts/weblist.pl release/tarball-root/dbus/weblist.pl

mkdir -p release/tarball-root/ice/
cp scripts/icedemo.php release/tarball-root/ice/icedemo.php
cp scripts/weblist.php release/tarball-root/ice/weblist.php
cp src/murmur/Murmur.ice release/tarball-root/ice/Murmur.ice

cp scripts/murmur.ini release/tarball-root/murmur.ini

cd release/
mv tarball-root murmur-static_x86-${ver}
mkdir -p tarball
chmod +x murmur-static_x86-${ver}/murmur.x86
tar --owner=root -cjpf tarball/murmur-static_x86-${ver}.tar.bz2 murmur-static_x86-${ver}
rm -rf murmur-static_x86-${ver}
