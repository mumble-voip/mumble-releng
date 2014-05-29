#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://python.org/ftp/python/2.7.6/Python-2.7.6.tgz"
expect_sha1 "Python-2.7.6.tgz" "8328d9f1d55574a287df384f4931a3942f03da64"
expect_sha256 "Python-2.7.6.tgz" "99c6860b70977befa1590029fae092ddb18db1d69ae67e8b9385b66ed104ba58"

tar -zxf Python-2.7.6.tgz
cd Python-2.7.6
./configure --prefix=${MUMBLE_PREFIX}
make
make install
