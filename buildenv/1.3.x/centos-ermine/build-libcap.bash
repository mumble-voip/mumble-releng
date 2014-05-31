#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://mirror.linux.org.au/linux/libs/security/linux-privs/libcap2/libcap-2.22.tar.bz2"
expect_sha1 "libcap-2.22.tar.bz2" "2136bc24fa35cdcbd00816fbbf312b727150256b"
expect_sha256 "libcap-2.22.tar.bz2" "73ebbd4877b5f69dd28b72098e510c5b318bc480f8201c4061ac98b78c04050f"

tar -jxf libcap-2.22.tar.bz2
cd libcap-2.22/libcap
make LIBATTR=no FAKEROOT=${MUMBLE_PREFIX} prefix=
make LIBATTR=no FAKEROOT=${MUMBLE_PREFIX} prefix= install

