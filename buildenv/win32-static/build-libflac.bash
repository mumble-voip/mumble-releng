#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/flac/flac-1.2.1.tar.gz"
expect_sha1 "flac-1.2.1.tar.gz" "bd54354900181b59db3089347cc84ad81e410b38"

tar -zxf flac-1.2.1.tar.gz
cd flac-1.2.1

cp -R ${MUMBLE_SNDFILE_PREFIX}/include/ogg include/ogg

cd src/libFLAC
cmd /c vcupgrade.exe -overwrite libFLAC_static.vcproj
sed -i -e 's,<RuntimeLibrary>MultiThreaded</RuntimeLibrary>,<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>,g' libFLAC_static.vcxproj
cmd /c set PATH="$(cygpath -w ${MUMBLE_PREFIX}/nasm);%PATH%" \&\& msbuild libFLAC_static.vcxproj /p:Configuration=Release

cd ../..
PREFIX=${MUMBLE_SNDFILE_PREFIX}

mkdir -p ${PREFIX}/lib
cp obj/release/lib/libFLAC_static.lib ${PREFIX}/lib/libFLAC.a
cat ${MUMBLE_BUILDENV_ROOT}/patches/libtool/libFLAC.la | \
	sed "s,@prefix@,${PREFIX},g" \
	> ${PREFIX}/lib/libFLAC.la

mkdir -p ${PREFIX}/include/FLAC
cp include/FLAC/*.h ${PREFIX}/include/FLAC/

mkdir -p ${PREFIX}/lib/pkgconfig
cat src/libFLAC/flac.pc.in | sed "s,@prefix@,${PREFIX},g;
                                  s,@exec_prefix@,\${prefix},g;
                                  s,@libdir@,\${prefix}/lib,g;
                                  s,@includedir@,\${prefix}\/include,g;
                                  s,@VERSION@,1.2.1,g;" > ${PREFIX}/lib/pkgconfig/flac.pc