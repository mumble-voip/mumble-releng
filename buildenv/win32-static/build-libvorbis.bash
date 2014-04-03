#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz"
expect_sha1 "libvorbis-1.3.4.tar.gz" "1602716c187593ffe4302124535240cec2079df3"

tar -zxf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/libvorbis-mumblebuild-props.patch

cd win32/VS2010

# Set /ARCH:IA32 for MSVS2012+.
if [ ${VSMAJOR} -gt 10 ]; then
  sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" libvorbis/libvorbis_static.vcxproj
  sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" libvorbisfile/libvorbisfile_static.vcxproj
fi

cmd /c msbuild.exe vorbis_static.sln /p:Configuration=Release /p:PlatformToolset=${MUMBLE_VSTOOLSET}

PREFIX=${MUMBLE_SNDFILE_PREFIX}

mkdir -p ${PREFIX}/lib

cp Win32/Release/libvorbis_static.lib ${PREFIX}/lib/libvorbis.a
cat ${MUMBLE_BUILDENV_ROOT}/patches/libtool/libvorbis.la | \
	sed "s,@prefix@,${PREFIX},g" \
	> ${PREFIX}/lib/libvorbis.la

# Use an empty libvorbisenc.a - on Windows, it's provided by libvoris itself.
echo -n > ${PREFIX}/lib/libvorbisenc.a
cat ${MUMBLE_BUILDENV_ROOT}/patches/libtool/libvorbisenc.la | \
    sed "s,@prefix@,${PREFIX},g" \
    > ${PREFIX}/lib/libvorbisenc.la

cp Win32/Release/libvorbisfile_static.lib ${PREFIX}/lib/libvorbisfile.a
cat ${MUMBLE_BUILDENV_ROOT}/patches/libtool/libvorbisfile.la | \
	sed "s,@prefix@,${PREFIX},g" \
	> ${PREFIX}/lib/libvorbisfile.la

cd ../..
mkdir -p ${PREFIX}/include/vorbis
cp include/vorbis/*.h ${PREFIX}/include/vorbis/

mkdir -p ${PREFIX}/lib/pkgconfig
cat vorbis.pc.in | sed "s,@prefix@,${PREFIX},g;
                        s,@exec_prefix@,\${prefix},g;
                        s,@libdir@,\${prefix}/lib,g;
                        s,@includedir@,\${prefix}\/include,g;
                        s,@VERSION@,1.3.4,g;" > ${PREFIX}/lib/pkgconfig/vorbis.pc
cat vorbisenc.pc.in | sed "s,@prefix@,${PREFIX},g;
                           s,@exec_prefix@,\${prefix},g;
                           s,@libdir@,\${prefix}/lib,g;
                           s,@includedir@,\${prefix}\/include,g;
                           s,@VERSION@,1.3.4,g;" > ${PREFIX}/lib/pkgconfig/vorbisenc.pc
cat vorbisfile.pc.in | sed "s,@prefix@,${PREFIX},g;
                            s,@exec_prefix@,\${prefix},g;
                            s,@libdir@,\${prefix}/lib,g;
                            s,@includedir@,\${prefix}\/include,g;
                            s,@VERSION@,1.3.4,g;" > ${PREFIX}/lib/pkgconfig/vorbisfile.pc
