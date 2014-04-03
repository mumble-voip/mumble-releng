#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://download.oracle.com/berkeley-db/db-5.3.28.tar.gz"
expect_sha1 "db-5.3.28.tar.gz" "fa3f8a41ad5101f43d08bc0efb6241c9b6fc1ae9"
expect_sha256 "db-5.3.28.tar.gz" "e0a992d740709892e81f9d93f06daf305cf73fb81b545afe72478043172c3628"

tar -zxf db-5.3.28.tar.gz
cd db-5.3.28/build_windows
patch -p2 < ${MUMBLE_BUILDENV_ROOT}/patches/db-runtime-mtdll.patch

# Set /ARCH:IA32 for MSVS2012+.
if [ ${VSMAJOR} -gt 10 ]; then
	sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" VS10/db.vcxproj
fi

cmd /c msbuild.exe Berkeley_DB_vs2010.sln /p:Configuration="Static Release" /p:PlatformToolset=${MUMBLE_VSTOOLSET} /target:db
mkdir -p ${MUMBLE_PREFIX}/berkeleydb/{lib,include}
cp Win32/Static\ Release/libdb53s.lib ${MUMBLE_PREFIX}/berkeleydb/lib/libdb53.lib
cp *.h ${MUMBLE_PREFIX}/berkeleydb/include/