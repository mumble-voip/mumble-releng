#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://download.oracle.com/berkeley-db/db-5.3.21.tar.gz"
expect_sha1 "db-5.3.21.tar.gz" "32e43c4898c8996750c958a90c174bd116fcba83"

tar -zxf db-5.3.21.tar.gz
cd db-5.3.21/build_windows
patch -p2 < ${MUMBLE_BUILDENV_ROOT}/patches/db-runtime-mtdll.patch
cmd /c msbuild.exe Berkeley_DB_vs2010.sln /p:Configuration="Static Release" /p:PlatformToolset=${MUMBLE_VSTOOLSET} /target:db
mkdir -p ${MUMBLE_PREFIX}/berkeleydb/{lib,include}
cp Win32/Static\ Release/libdb53s.lib ${MUMBLE_PREFIX}/berkeleydb/lib/libdb53.lib
cp *.h ${MUMBLE_PREFIX}/berkeleydb/include/