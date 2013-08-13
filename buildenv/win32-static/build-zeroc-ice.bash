#!/bin/bash -e
SHA1="136e683c749c84cd197c43daa6f344a5828d7c46"
curl -L -O "http://www.zeroc.com/download/Ice/3.5/Ice-3.5.0.zip"
if [ "$(shasum -a 1 Ice-3.5.0.zip | cut -b -40)" != "${SHA1}" ]; then
	echo zeroc ice checksum mismatch
	exit
fi

unzip Ice-3.5.0.zip
cd Ice-3.5.0/cpp
patch -p2 < ../../patches/zeroc-ice-3.5.0-win32-static.diff
patch -p2 --binary < ../../patches/zeroc-ice-3.5.0-msvc-custom-prefix.patch
patch -p2 < ../../patches/zeroc-ice-3.5.0-iceutil-c++11-for-MSVS2012-only.diff

export ICE_ARFLAGS="/ignore:4221"
export ICE_LDFLAGS="user32.lib gdi32.lib dbghelp.lib wsock32.lib ws2_32.lib iphlpapi.lib mcpp.lib libbz2.lib libexpat.lib libeay32.lib libdb53.lib /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/mcpp) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/bzip2/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/expat/lib) /LIBPATH:$(cygpath -w ${MUMBLE_PREFIX}/berkeleydb/lib)"
export ICE_CPPFLAGS="/DXML_STATIC /I$(cygpath -w ${MUMBLE_PREFIX}/bzip2/include) /I$(cygpath -w ${MUMBLE_PREFIX}/OpenSSL/include) /I$(cygpath -w ${MUMBLE_PREFIX}/expat/include) /I$(cygpath -w ${MUMBLE_PREFIX}/berkeleydb/include)"

cmd /c nmake /f Makefile.mak PREFIX="$(cygpath -w ${MUMBLE_PREFIX}/ZeroC-Ice)" STATICLIBS=yes OPTIMIZE=yes GENERATE_PDB=no HAS_MFC=no ARFLAGS="${ICE_ARFLAGS}" LDFLAGS="${ICE_LDFLAGS}" CPPFLAGS="${ICE_CPPFLAGS}"
cmd /c nmake /f Makefile.mak PREFIX="$(cygpath -w ${MUMBLE_PREFIX}/ZeroC-Ice)" STATICLIBS=yes OPTIMIZE=yes GENERATE_PDB=no HAS_MFC=no ARFLAGS="${ICE_ARFLAGS}" LDFLAGS="${ICE_LDFLAGS}" CPPFLAGS="${ICE_CPPFLAGS}" install