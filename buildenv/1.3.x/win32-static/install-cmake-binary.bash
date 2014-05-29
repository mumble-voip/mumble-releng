#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.cmake.org/files/v2.8/cmake-2.8.12.1-win32-x86.zip"
expect_sha1 "cmake-2.8.12.1-win32-x86.zip" "6a27d8fcf887774e56fa165eddd5242e1c350464"

unzip -o cmake-2.8.12.1-win32-x86.zip
mkdir -p ${MUMBLE_PREFIX}/cmake/
cp -R cmake-2.8.12.1-win32-x86/* ${MUMBLE_PREFIX}/cmake/
chmod +rx ${MUMBLE_PREFIX}/cmake/bin/*.{dll,exe}