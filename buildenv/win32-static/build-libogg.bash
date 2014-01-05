#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/ogg/libogg-1.3.0.tar.gz"
expect_sha1 "libogg-1.3.0.tar.gz" "a900af21b6d7db1c7aa74eb0c39589ed9db991b8"

tar -zxf libogg-1.3.0.tar.gz
cd libogg-1.3.0
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/ogg-static-vs2010-Zi.patch

# Generate config_types.h so we can use the MSVS2010 libogg with MinGW.
./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --disable-shared --enable-static

cd win32/VS2010
cmd /c msbuild.exe libogg_static.sln /p:Configuration=Release /p:PlatformToolset=${MUMBLE_VSTOOLSET}

PREFIX=${MUMBLE_SNDFILE_PREFIX}

mkdir -p ${PREFIX}/lib
cp Win32/Release/libogg_static.lib ${PREFIX}/lib/libogg.a
cat ${MUMBLE_BUILDENV_ROOT}/patches/libtool/libogg.la | \
	sed "s,@libdir@,${PREFIX}/lib,g" \
	> ${PREFIX}/lib/libogg.la

cd ../..
mkdir -p ${PREFIX}/include/ogg
cp include/ogg/*.h ${PREFIX}/include/ogg/

mkdir -p ${PREFIX}/lib/pkgconfig
cat ogg.pc.in | sed "s,@prefix@,${PREFIX},g;
                     s,@exec_prefix@,\${prefix},g;
                     s,@libdir@,\${prefix}/lib,g;
                     s,@includedir@,\${prefix}\/include,g;
                     s,@VERSION@,1.3.0,g;" > ${PREFIX}/lib/pkgconfig/ogg.pc