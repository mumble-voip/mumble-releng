#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.xz"
expect_sha1 "libogg-1.3.1.tar.xz" "a4242415a7a9fd71f3092af9ff0b9fa630e4d7bd"
expect_sha256 "libogg-1.3.1.tar.xz" "3a5bad78d81afb78908326d11761c0fb1a0662ee7150b6ad587cc586838cdcfa"

tar -Jxf libogg-1.3.1.tar.xz
cd libogg-1.3.1
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/ogg-static-vs2010-Zi.patch

# Generate config_types.h so we can use the MSVS2010 libogg with MinGW.
./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --disable-shared --enable-static

cd win32/VS2010

sed -i -e 's,<RuntimeLibrary>MultiThreaded</RuntimeLibrary>,<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>,g' libogg_static.vcxproj

# Set /ARCH:IA32 for MSVS2012+.
if [ ${VSMAJOR} -gt 10 ]; then
	sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" libogg_static.vcxproj
fi

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
                     s,@VERSION@,1.3.1,g;" > ${PREFIX}/lib/pkgconfig/ogg.pc