#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz"
expect_sha1 "bzip2-1.0.6.tar.gz" "3f89f861209ce81a6bab1fd1998c0ef311712002"

tar -zxf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/bzip2-linker-pdb.patch
cmd /c nmake /f makefile.msc
mkdir -p ${MUMBLE_PREFIX}/bzip2/{include,lib}
cp libbz2.lib ${MUMBLE_PREFIX}/bzip2/lib/
cp bzlib.h ${MUMBLE_PREFIX}/bzip2/include/