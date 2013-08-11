#!/bin/bash
#
# Copyright (C) 2013 Mikkel Krautz <mikkel@krautz.dk>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# - Neither the name of the Mumble Developers nor the names of its
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# `AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}"

# Create an object file with the magic SafeSEH symbol.
# The symbol '@feat.00' with a value of 1 signals to link.exe
# that the object file, signalling that the object is compatible
# with the safe exception handling feature.
echo "" | i686-pc-mingw32-as --defsym @feat.00=1 -o safeseh.o

# extract_obj takes two arguments:
#  1. An absolute path to to a statlic library (.a)
#     whose objects shall be extracted.
#  2. A short name which will be used as the name of directory
#     (in CWD) to hold the resulting object files, as well as
#     the prefix for the object files.
# 
# It extracts all object files from the archive, and
# prepends "${SHORT_NAME}___" to their file name. This
# namespacing is done to allow us to merge the object
# files from multiple static libraries without fearing
# name clashes.
#
# The resulting, prefixed, object files will also be
# marked as SafeSEH compatible.
function extract_obj {
	ABS_ARCHIVE=${1}
	SHORT_NAME=${2}

	mkdir -p ${SHORT_NAME}
	cd ${SHORT_NAME}

	i686-pc-mingw32-ar x "${ABS_ARCHIVE}"
	for fn in `ls`; do
		# Combine the original object with safeseh.o to mark the resulting
		# object as SafeSEH compatible.
		i686-pc-mingw32-ld -r ../safeseh.o ${fn} -o ${SHORT_NAME}___${fn}
		rm -f ${fn}
	done
	cd ..
}

extract_obj "$(i686-pc-mingw32-gcc --print-libgcc)" libgcc
extract_obj "$(i686-pc-mingw32-gcc --print-sysroot)/mingw/lib/libmingwex.a" libmingwex
extract_obj "${MUMBLE_PREFIX}/lib/libFLAC.a" flac
extract_obj "${MUMBLE_PREFIX}/lib/libogg.a" ogg
extract_obj "${MUMBLE_PREFIX}/lib/libvorbis.a" vorbis
extract_obj "${MUMBLE_PREFIX}/lib/libvorbisenc.a" vorbisenc
extract_obj "${MUMBLE_PREFIX}/lib/libvorbisfile.a" vorbisfile
extract_obj "${MUMBLE_PREFIX}/lib/libsndfile.a" sndfile

# Combine all the extracted objects into 'libsndfile-1.lib'.
# This name is the same that the Win32 DLL distribution of libsndfile
# uses, allowing this static version to be a drop-in replacement.
rm -f "${MUMBLE_PREFIX}/lib/libsndfile-1.lib"
i686-pc-mingw32-ar rcs "${MUMBLE_PREFIX}/lib/libsndfile-1.lib" \
	libgcc/*.o \
	libmingwex/*.o \
	flac/*.o \
	ogg/*.o \
	vorbis/*.o \
	vorbisenc/*.o \
	vorbisfile/*.o \
	sndfile/*.o
rm -rf "${TEMPDIR}"
