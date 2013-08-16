#!/bin/bash
SHA1="4c4e70517deb2fac4aa1e6390ce7535d7a50206b"
curl -O "http://www.nasm.us/pub/nasm/releasebuilds/2.10.09/win32/nasm-2.10.09-win32.zip"
if [ "$(shasum -a 1 nasm-2.10.09-win32.zip | cut -b -40)" != "${SHA1}" ]; then
	echo nasm binary checksum mismatch
	exit
fi

unzip -o nasm-2.10.09-win32.zip
mkdir -p ${MUMBLE_PREFIX}/nasm/
cp -R nasm-2.10.09/* ${MUMBLE_PREFIX}/nasm/
chmod -R +rx ${MUMBLE_PREFIX}/nasm/*