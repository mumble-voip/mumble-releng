#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.cmake.org/files/v2.8/cmake-2.8.12.1-win32-x86.zip"
expect_sha1 "cmake-2.8.12.1-win32-x86.zip" "6a27d8fcf887774e56fa165eddd5242e1c350464"

unzip -o cmake-2.8.12.1-win32-x86.zip
mkdir -p ${MUMBLE_PREFIX}/cmake/
cp -R cmake-2.8.12.1-win32-x86/* ${MUMBLE_PREFIX}/cmake/
chmod +rx ${MUMBLE_PREFIX}/cmake/bin/*.{dll,exe}