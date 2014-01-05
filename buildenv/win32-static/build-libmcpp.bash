#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.sourceforge.net/project/mcpp/mcpp/V.2.7.2/mcpp-2.7.2.tar.gz"
expect_sha1 "mcpp-2.7.2.tar.gz" "703356b7c2cd30d7fb6000625bf3ccc2eb977ecb"

tar -zxf mcpp-2.7.2.tar.gz
cd mcpp-2.7.2
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/zeroc-patch.mcpp.2.7.2
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/mcpp-pdb.patch
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/mcpp-mtdll.patch
cd src
patch --binary -p0 < ../noconfig/vc2010.dif
cmd /c nmake MCPP_LIB=1 /f ..\\noconfig\\visualc.mak mcpplib_lib
mkdir -p ${MUMBLE_PREFIX}/mcpp/
cp mcpp.lib ${MUMBLE_PREFIX}/mcpp/