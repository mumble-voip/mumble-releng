#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.openssl.org/source/openssl-1.0.0k.tar.gz"
expect_sha1 "openssl-1.0.0k.tar.gz" "ec5d20f1ee52ae765b9286e9d7951dcfc9548607"

tar -zxf openssl-1.0.0k.tar.gz
cd openssl-1.0.0k
./Configure debug-VC-WIN32 no-shared --prefix=$(cygpath -w "${MUMBLE_PREFIX}/OpenSSL")
cmd /c ms\\do_nasm
cmd /c set PATH="$(cygpath -w ${MUMBLE_PREFIX}/nasm);%PATH%" \&\& nmake -f ms\\nt.mak
cmd /c nmake -f ms\\nt.mak test
cmd /c nmake -f ms\\nt.mak install