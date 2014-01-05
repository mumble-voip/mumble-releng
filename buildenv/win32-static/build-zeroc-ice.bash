#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.zeroc.com/download/Ice/3.5/Ice-3.5.1.zip"
expect_sha1 "Ice-3.5.1.zip" "9127c9c16d5b44d24a78d0d8afb908aace2b0287"

unzip -o Ice-3.5.1.zip
cd Ice-3.5.1/cpp
patch -p2 < ${MUMBLE_BUILDENV_ROOT}/patches/zeroc-ice-3.5.0-win32-static.diff
patch -p2 --binary < ${MUMBLE_BUILDENV_ROOT}/patches/zeroc-ice-3.5.0-msvc-custom-prefix.patch
patch -p2 < ${MUMBLE_BUILDENV_ROOT}/patches/zeroc-ice-3.5.1-iceutil-c++11-for-MSVS2012-and-greater.diff
patch -p2 < ${MUMBLE_BUILDENV_ROOT}/patches/zeroc-ice-3.5.1-msvc2013.patch

export ICE_ARFLAGS="/ignore:4221"
export ICE_LDFLAGS="user32.lib gdi32.lib dbghelp.lib wsock32.lib ws2_32.lib iphlpapi.lib mcpp.lib libbz2.lib libexpat.lib libeay32.lib libdb53.lib /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/mcpp) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/bzip2/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/expat/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/berkeleydb/lib)"
export ICE_CPPFLAGS="/DXML_STATIC /I$(cygpath -w ${MUMBLE_PREFIX}/bzip2/include) /I$(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/include) /I$(cygpath -w ${MUMBLE_PREFIX}/expat/include) /I$(cygpath -w ${MUMBLE_PREFIX}/berkeleydb/include)"

# Build with RELEASEPDBS=yes to have cl.exe generate .pdbs
cmd /c nmake /f Makefile.mak PREFIX="$(cygpath -w ${MUMBLE_PREFIX}/ZeroC-Ice)" STATICLIBS=yes OPTIMIZE=yes RELEASEPDBS=yes HAS_MFC=no ARFLAGS="${ICE_ARFLAGS}" LDFLAGS="${ICE_LDFLAGS}" CPPFLAGS="${ICE_CPPFLAGS}"
# Perform install with RELEASEPDBS=no to avoid having the
# Makefiles attempt to copy non-existant DLL PDBs.
# TODO: Fix up zeroc-ice-3.5.0-win32-static.diff to not
# attempt to install .pdbs for static libraries.
cmd /c nmake /f Makefile.mak PREFIX="$(cygpath -w ${MUMBLE_PREFIX}/ZeroC-Ice)" STATICLIBS=yes OPTIMIZE=yes RELEASEPDBS=no HAS_MFC=no ARFLAGS="${ICE_ARFLAGS}" LDFLAGS="${ICE_LDFLAGS}" CPPFLAGS="${ICE_CPPFLAGS}" install