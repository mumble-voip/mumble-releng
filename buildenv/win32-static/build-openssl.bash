#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.openssl.org/source/openssl-1.0.0k.tar.gz"
expect_sha1 "openssl-1.0.0k.tar.gz" "ec5d20f1ee52ae765b9286e9d7951dcfc9548607"

tar -zxf openssl-1.0.0k.tar.gz
cd openssl-1.0.0k

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