#!/bin/bash
rm -rf xar.git
git clone https://github.com/mkrautz/xar xar.git
cd xar.git/xar
export CFLAGS="-I$OSX_SDK/usr/include/libxml2 ${CFLAGS} -I${MUMBLE_PREFIX}/include/"
export LDFLAGS="${LDFLAGS} -L${MUMBLE_PREFIX}/lib/"
./autogen.sh --prefix=${MUMBLE_PREFIX} --disable-shared --enable-static
make
make install
