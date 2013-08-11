#!/bin/bash
SHA1="ec5d20f1ee52ae765b9286e9d7951dcfc9548607"
curl -O http://www.openssl.org/source/openssl-1.0.0k.tar.gz
if [ "$(shasum -a 1 openssl-1.0.0k.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo openssl checksum mismatch
	exit
fi
tar -zxf openssl-1.0.0k.tar.gz
cd openssl-1.0.0k
./Configure VC-WIN32 no-shared --prefix=$(cygpath -w "${MUMBLE_PREFIX}/OpenSSL")
cmd /c ms\\do_nasm
cmd /c nmake -f ms\\nt.mak
cmd /c nmake -f ms\\nt.mak test
cmd /c nmake -f ms\\nt.mak install