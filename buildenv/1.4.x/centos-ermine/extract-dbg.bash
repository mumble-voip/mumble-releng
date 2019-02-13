#!/bin/bash
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

SYMBOLS_DIR=${MUMBLE_PREFIX}/symbols
for fn in $(find ${MUMBLE_PREFIX}); do
	file ${fn} | grep -q "ELF"
	if [ $? -eq 0 ]; then
		if [ ! -h "${fn}" ]; then
			chmod +w ${fn}
			dbgfn=${SYMBOLS_DIR}${fn##$MUMBLE_PREFIX}.dbg
			mkdir -p $(dirname ${dbgfn})
			objcopy --only-keep-debug ${fn} ${dbgfn}
			objcopy --strip-debug ${fn}
			chmod -x ${dbgfn}
		fi
	fi
done
