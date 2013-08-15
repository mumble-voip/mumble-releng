#!/bin/bash
SHA1="3f01703006aa3c2cd0d796c0f23775eb7f7b3dc7"
curl -O "http://www.cmake.org/files/v2.8/cmake-2.8.11.2-win32-x86.zip"
if [ "$(shasum -a 1 cmake-2.8.11.2-win32-x86.zip | cut -b -40)" != "${SHA1}" ]; then
	echo cmake binary checksum mismatch
	exit
fi

unzip -o cmake-2.8.11.2-win32-x86.zip
mkdir -p ${MUMBLE_PREFIX}/cmake/
cp -R cmake-2.8.11.2-win32-x86/* ${MUMBLE_PREFIX}/cmake/
chmod +rx ${MUMBLE_PREFIX}/cmake/bin/*.{dll,exe}