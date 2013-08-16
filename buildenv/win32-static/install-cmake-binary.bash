#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.cmake.org/files/v2.8/cmake-2.8.11.2-win32-x86.zip"
expect_sha1 "cmake-2.8.11.2-win32-x86.zip" "3f01703006aa3c2cd0d796c0f23775eb7f7b3dc7"

unzip -o cmake-2.8.11.2-win32-x86.zip
mkdir -p ${MUMBLE_PREFIX}/cmake/
cp -R cmake-2.8.11.2-win32-x86/* ${MUMBLE_PREFIX}/cmake/
chmod +rx ${MUMBLE_PREFIX}/cmake/bin/*.{dll,exe}