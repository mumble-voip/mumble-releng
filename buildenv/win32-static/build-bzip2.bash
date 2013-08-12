#!/bin/bash
set -e
SHA1="3f89f861209ce81a6bab1fd1998c0ef311712002"
curl -O "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
if [ "$(sha1sum bzip2-1.0.6.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo bzip2 checksum mismatch
	exit
fi
tar -zxf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
cmd /c nmake /f makefile.msc
mkdir -p ${MUMBLE_PREFIX}/bzip2/{include,lib}
cp libbz2.lib ${MUMBLE_PREFIX}/bzip2/lib/
cp bzlib.h ${MUMBLE_PREFIX}/bzip2/include/