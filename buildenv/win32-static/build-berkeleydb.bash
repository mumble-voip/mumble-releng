#!/bin/bash
set -e
SHA1="32e43c4898c8996750c958a90c174bd116fcba83"
curl -O "http://download.oracle.com/berkeley-db/db-5.3.21.tar.gz"
if [ "$(sha1sum db-5.3.21.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo berkeleydb checksum mismatch
	exit
fi
tar -zxf db-5.3.21.tar.gz
cd db-5.3.21/build_windows
patch -p2 < ../../patches/db-runtime-mtdll.patch
cmd /c msbuild.exe Berkeley_DB_vs2010.sln /p:Configuration="Static Release" /target:db
mkdir -p ${MUMBLE_PREFIX}/berkeleydb/{lib,include}
cp Win32/Static\ Release/libdb53s.lib ${MUMBLE_PREFIX}/berkeleydb/lib/libdb53.lib
cp *.h ${MUMBLE_PREFIX}/berkeleydb/include/