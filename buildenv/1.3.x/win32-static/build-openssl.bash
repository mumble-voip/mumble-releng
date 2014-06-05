#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://www.openssl.org/source/openssl-1.0.0m.tar.gz"
expect_sha1 "openssl-1.0.0m.tar.gz" "039041fd00f45a0f485ca74f85209b4101a43a0f"
expect_sha256 "openssl-1.0.0m.tar.gz" "224dbbfaee3ad7337665e24eab516c67446d5081379a40b2f623cf7801e672de"

tar -zxf openssl-1.0.0m.tar.gz
cd openssl-1.0.0m

./Configure VC-WIN32 no-shared --prefix=$(cygpath -w "${MUMBLE_PREFIX}/OpenSSL")
cmd /c ms\\do_nasm

# The do_nasm script leaves a stale NUL file when called
# with cygwin perl. The file isn't obviously removable from
# explorer.exe because it's a reserved name.
# We'll be friendly and remove it here. :-)
rm -rf ./NUL

# Change /MT to /MD (MultiThreaded -> MultiThreadedDLL)
sed -i -e 's,/MT ,/MD ,g' ms/nt.mak

cmd /c set PATH="$(cygpath -w ${MUMBLE_PREFIX}/nasm);%PATH%" \&\& nmake -f ms\\nt.mak
cmd /c nmake -f ms\\nt.mak test
cmd /c nmake -f ms\\nt.mak install