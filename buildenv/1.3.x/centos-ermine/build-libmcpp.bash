#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://downloads.sourceforge.net/project/mcpp/mcpp/V.2.7.2/mcpp-2.7.2.tar.gz"
expect_sha1 "mcpp-2.7.2.tar.gz" "703356b7c2cd30d7fb6000625bf3ccc2eb977ecb"
expect_sha256 "mcpp-2.7.2.tar.gz" "3b9b4421888519876c4fc68ade324a3bbd81ceeb7092ecdbbc2055099fcb8864"

tar -zxf mcpp-2.7.2.tar.gz
cd mcpp-2.7.2
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/zeroc-patch.mcpp.2.7.2
./configure --prefix=${MUMBLE_PREFIX} --enable-mcpplib
make
make install
