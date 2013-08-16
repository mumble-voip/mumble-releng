#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.nasm.us/pub/nasm/releasebuilds/2.10.09/win32/nasm-2.10.09-win32.zip"
expect_sha1 "nasm-2.10.09-win32.zip" "4c4e70517deb2fac4aa1e6390ce7535d7a50206b"

unzip -o nasm-2.10.09-win32.zip
mkdir -p ${MUMBLE_PREFIX}/nasm/
cp -R nasm-2.10.09/* ${MUMBLE_PREFIX}/nasm/
chmod -R +rx ${MUMBLE_PREFIX}/nasm/*