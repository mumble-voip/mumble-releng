#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.zip"
expect_sha1 "boost_1_55_0.zip" "1d479557177c49d74001c904979b60cce8cc2d12"

unzip -q -o boost_1_55_0.zip
cd boost_1_55_0

patch -p0 --binary < ${MUMBLE_BUILDENV_ROOT}/patches/boost/001-log_fix_dump_avx2.patch
patch -p2 --binary < ${MUMBLE_BUILDENV_ROOT}/patches/boost/1_55_0-vc2013-fixes/changeset-86595.patch
patch -p2 --binary < ${MUMBLE_BUILDENV_ROOT}/patches/boost/1_55_0-vc2013-fixes/changeset-86626.patch
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/boost/0005-Boost.S11n-include-missing-algorithm.patch

cmd /c bootstrap.bat

printf "// Automatically added by the Mumble win32-static build environment.\n" >> boost/config/user.hpp
printf "#define BOOST_AUTO_LINK_TAGGED 1\n" >> boost/config/user.hpp

BOOST_TOOLSET=msvc-${VSVER}
cmd /c b2 --toolset=${BOOST_TOOLSET} --prefix=$(cygpath -w "${MUMBLE_PREFIX}/Boost") --without-mpi --without-python --layout=tagged link=static runtime-link=shared install
