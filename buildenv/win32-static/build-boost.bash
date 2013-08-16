#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.sourceforge.net/project/boost/boost/1.54.0/boost_1_54_0.zip"
expect_sha1 "boost_1_54_0.zip" "88b50519da5f9b272b1560f02745773f51bcf766"

unzip boost_1_54_0.zip
cd boost_1_54_0
cmd /c bootstrap.bat
cmd /c b2 --toolset=msvc-10.0 --prefix=$(cygpath -w "${MUMBLE_PREFIX}/Boost") install
