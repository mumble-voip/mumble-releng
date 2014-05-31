#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.nasm.us/pub/nasm/releasebuilds/2.11/win32/nasm-2.11-win32.zip"
expect_sha1 "nasm-2.11-win32.zip" "d02cd111fc74daaf901a714d4d325fef5f769224"
expect_sha256 "nasm-2.11-win32.zip" "abcad8089bdf03c10e0cd621415ae71cd8289d346000ee8b1e8aaf27f6d98de9"

unzip -o nasm-2.11-win32.zip
mkdir -p ${MUMBLE_PREFIX}/nasm/
cp -R nasm-2.11/* ${MUMBLE_PREFIX}/nasm/

# FLAC's MSVC build wants nasmw.exe.
cp ${MUMBLE_PREFIX}/nasm/nasm.exe ${MUMBLE_PREFIX}/nasm/nasmw.exe

chmod -R +rx ${MUMBLE_PREFIX}/nasm/*