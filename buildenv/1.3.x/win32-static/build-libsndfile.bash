#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz"
expect_sha1 "libsndfile-1.0.25.tar.gz" "e95d9fca57f7ddace9f197071cbcfb92fa16748e"

tar -zxf libsndfile-1.0.25.tar.gz
cd libsndfile-1.0.25

patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/libsndfile-sys-time-h.diff
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/libsndfile-1.0.25-msvc-compat.patch

# Fix the things that libsndfile-1.0.25-msvc-compat.patch broke.
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/libsndfile-1.0.25-common-h-stdarg.patch
patch -p1 < ${MUMBLE_BUILDENV_ROOT}/patches/libsndfile-1.0.25-msc-ver-fixes.patch

# Visual Studio 2013 or greater.
if [ $VSMAJOR -ge 12 ]; then
	# Avoid gyp duplicate basename error.
	mv src/g72x.c src/g72xsf.c

	cd Win32

	mkdir -p tests
	cp ${MUMBLE_BUILDENV_ROOT}/patches/test_vsnprintf.c tests/test_vsnprintf.c

	mkdir -p include
	cp ../src/sndfile.h.in include/sndfile.h

	mkdir -p include/x86
	cp ${MUMBLE_BUILDENV_ROOT}/patches/libsndfile-config-win32-x86.h include/x86/config.h

	rm -rf build
	cp ${MUMBLE_BUILDENV_ROOT}/gypfiles/libsndfile.gyp .

	set GYP_MSVS_VERSION=2013
	cmd /c $(cygpath -w ${MUMBLE_PREFIX}/mumble-releng/gyp/gyp.bat) libsndfile.gyp -f msvs --depth .. -Dlibrary=static_library --generator-out=build
	cmd /c msbuild $(cygpath -w build/libsndfile.sln) /m /target:libsndfile /p:PlatformToolset=${MUMBLE_VSTOOLSET}

	cmd /c msbuild $(cygpath -w build/libsndfile.sln) /m /target:test_vsnprintf /p:PlatformToolset=${MUMBLE_VSTOOLSET}
	set +e
	cmd /c $(cygpath -w build/Default/test_vsnprintf.exe)
	set -e

	cp build/Default/lib/sndfile.lib ${MUMBLE_PREFIX}/sndfile/lib/libsndfile.a
	cp include/sndfile.h ${MUMBLE_PREFIX}/sndfile/include/

# Fall back to MinGW build
else
	./configure --host=i686-pc-mingw32 --prefix=${MUMBLE_SNDFILE_PREFIX} --disable-shared --enable-static --disable-sqlite
	cp src/config.h src/config.h.orig

	# Avoid gettimeofday() and snprintf(), which
	# would require linking against libmingwex.a.
	cat src/config.h.orig | grep -v HAVE_GETTIMEOFDAY > src/config.h
	echo "#define HAVE_GETTIMEOFDAY 0" >> src/config.h

	cd src
	make
	make install
fi
