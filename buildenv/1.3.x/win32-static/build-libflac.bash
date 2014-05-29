#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.xiph.org/releases/flac/flac-1.3.0.tar.xz"
expect_sha1 "flac-1.3.0.tar.xz" "a136e5748f8fb1e6c524c75000a765fc63bb7b1b"
expect_sha256 "flac-1.3.0.tar.xz" "fa2d64aac1f77e31dfbb270aeb08f5b32e27036a52ad15e69a77e309528010dc"

tar -Jxf flac-1.3.0.tar.xz
cd flac-1.3.0

cp -R ${MUMBLE_SNDFILE_PREFIX}/include/ogg include/ogg

cd src/share/utf8
cmd /c vcupgrade.exe -overwrite utf8_static.vcproj
sed -i -e 's,<RuntimeLibrary>MultiThreaded</RuntimeLibrary>,<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>,g' utf8_static.vcxproj
# Set /ARCH:IA32 for MSVS2012+.
if [ ${VSMAJOR} -gt 10 ]; then
	sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" utf8_static.vcxproj
fi
cmd /c msbuild utf8_static.vcxproj /p:Configuration=Release /p:PlatformToolset=${MUMBLE_VSTOOLSET}
cd ../../..

cd src/share/win_utf8_io
cmd /c vcupgrade.exe -overwrite win_utf8_io.vcproj
sed -i -e 's,<RuntimeLibrary>MultiThreaded</RuntimeLibrary>,<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>,g' win_utf8_io.vcxproj
# Set /ARCH:IA32 for MSVS2012+.
if [ ${VSMAJOR} -gt 10 ]; then
	sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" win_utf8_io.vcxproj
fi
cmd /c msbuild win_utf8_io.vcxproj /p:Configuration=Release /p:PlatformToolset=${MUMBLE_VSTOOLSET}
cd ../../..

cd src/libFLAC
cmd /c vcupgrade.exe -overwrite libFLAC_static.vcproj
sed -i -e 's,<RuntimeLibrary>MultiThreaded</RuntimeLibrary>,<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>,g' libFLAC_static.vcxproj
# Set /ARCH:IA32 for MSVS2012+.
if [ ${VSMAJOR} -gt 10 ]; then
	sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" libFLAC_static.vcxproj
fi
cmd /c set PATH="$(cygpath -w ${MUMBLE_PREFIX}/nasm);%PATH%" \&\& msbuild libFLAC_static.vcxproj /p:Configuration=Release /p:PlatformToolset=${MUMBLE_VSTOOLSET}
cd ../..

PREFIX=${MUMBLE_SNDFILE_PREFIX}

mkdir -p ${PREFIX}/lib
cmd /c lib.exe /ltcg /out:$(cygpath -w ${PREFIX}/lib/libFLAC.a) \
		"$(cygpath -w objs/release/lib/libFLAC_static.lib)" \
		"$(cygpath -w objs/release/lib/utf8_static.lib)" \
		"$(cygpath -w objs/release/lib/win_utf8_io.lib)"
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
                                  s,@OGG_PACKAGE@,ogg >= 1.3.1,g;
                                  s,@VERSION@,1.3.0,g;" > ${PREFIX}/lib/pkgconfig/flac.pc