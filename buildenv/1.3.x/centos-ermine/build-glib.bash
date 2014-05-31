#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "ftp://ftp.gnome.org/pub/gnome/sources/glib/2.38/glib-2.38.2.tar.xz"
expect_sha1 "glib-2.38.2.tar.xz" "685c5a4215b776b83dd5330ab9084c5dcb0a51b8"
expect_sha256 "glib-2.38.2.tar.xz" "056a9854c0966a0945e16146b3345b7a82562a5ba4d5516fd10398732aea5734"

xzcat glib-2.38.2.tar.xz | tar -xf -
cd glib-2.38.2
export CFLAGS="-march=i486"
./configure --prefix=$MUMBLE_PREFIX
make
make install
