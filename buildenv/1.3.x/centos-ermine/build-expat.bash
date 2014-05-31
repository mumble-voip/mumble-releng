#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz"
expect_sha1 "expat-2.1.0.tar.gz" "b08197d146930a5543a7b99e871cba3da614f6f0"
expect_sha256 "expat-2.1.0.tar.gz" "823705472f816df21c8f6aa026dd162b280806838bb55b3432b0fb1fcca7eb86"

tar -zxf expat-2.1.0.tar.gz
cd expat-2.1.0
./configure --prefix=${MUMBLE_PREFIX}
make
make install
