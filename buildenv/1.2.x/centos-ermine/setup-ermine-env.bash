#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

eval "echo -e \"$(<ermine.conf.in)\"" > ${MUMBLE_PREFIX}/etc/ermine.conf
install -m 0755 ../../tools/dump-ermine-elfs.py ${MUMBLE_PREFIX}/bin/dump-ermine-elfs.py
install -m 0755 ../../tools/zero-ermine-ld.py ${MUMBLE_PREFIX}/bin/zero-ermine-ld.py
