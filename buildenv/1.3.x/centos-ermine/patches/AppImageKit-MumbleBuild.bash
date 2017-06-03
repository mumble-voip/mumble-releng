#!/bin/bash -ex
#
# MIT License
#
# Copyright (c) 2004-16 Simon Peter
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This is a slightly modified
# version of build.sh from AppImageKit,
# adjusted to work in a Mumble build
# environment.

# Clean up from previous run
rm -rf build/
mkdir build
cd build

# Compile runtime but do not link
gcc -DVERSION_NUMBER=\"$(git describe --tags --always --abbrev=7)\" -I${MUMBLE_PREFIX}/include/squashfuse -D_FILE_OFFSET_BITS=64 -g -Os -c ../runtime.c

# Prepare 1024 bytes of space for updateinformation
printf '\0%.0s' {0..1023} > 1024_blank_bytes

objcopy --add-section .upd_info=1024_blank_bytes \
          --set-section-flags .upd_info=noload,readonly runtime.o runtime2.o

objcopy --add-section .sha256_sig=1024_blank_bytes \
          --set-section-flags .sha256_sig=noload,readonly runtime2.o runtime3.o

# Now statically link against libsquashfuse_ll, libsquashfuse
# and embed .upd_info and .sha256_sig sections
gcc ../elf.c ../notify.c ../getsection.c runtime3.o ${MUMBLE_PREFIX}/lib/libsquashfuse_ll.a ${MUMBLE_PREFIX}/lib/libsquashfuse.a ${MUMBLE_PREFIX}/lib/libfuseprivate.a -L${MUMBLE_PREFIX}/lib -Wl,-Bdynamic -lfuse -lpthread -lz -Wl,-Bdynamic -ldl -o runtime
strip runtime

# Test if we can read it back
readelf -x .upd_info runtime # hexdump

# The raw updateinformation data can be read out manually like this:
HEXOFFSET=$(objdump -h runtime | grep .upd_info | awk '{print $6}')
HEXLENGTH=$(objdump -h runtime | grep .upd_info | awk '{print $3}')
dd bs=1 if=runtime skip=$(($(echo 0x$HEXOFFSET)+0)) count=$(($(echo 0x$HEXLENGTH)+0)) | xxd

# Insert AppImage magic bytes

printf '\x41\x49\x02' | dd of=runtime bs=1 seek=8 count=3 conv=notrunc

# Convert runtime into a data object that can be embedded into appimagetool

ld -r -b binary -o data.o runtime

# Compile and link digest tool
gcc -o digest ../getsection.c ../digest.c -L${MUMBLE_PREFIX}/lib -I${MUMBLE_PREFIX}/include -I${MUMBLE_PREFIX}/include/squashfuse -Wl,-Bstatic -lssl -lcrypto -Wl,-Bdynamic -lz -ldl # 1.4 MB
strip digest

# Test if we can read it back
readelf -x .upd_info runtime # hexdump

# The raw updateinformation data can be read out manually like this:
HEXOFFSET=$(objdump -h runtime | grep .upd_info | awk '{print $6}')
HEXLENGTH=$(objdump -h runtime | grep .upd_info | awk '{print $3}')
dd bs=1 if=runtime skip=$(($(echo 0x$HEXOFFSET)+0)) count=$(($(echo 0x$HEXLENGTH)+0)) | xxd

# Convert runtime into a data object that can be embedded into appimagetool
ld -r -b binary -o data.o runtime

# Compile appimagetool but do not link - glib version
gcc -DVERSION_NUMBER=\"$(git describe --tags --always --abbrev=7)\" -D_FILE_OFFSET_BITS=64 -I${MUMBLE_PREFIX}/include/squashfuse $(pkg-config --cflags glib-2.0) -g -Os ../getsection.c  -c ../appimagetool.c

# Now statically link against libsquashfuse - glib version
export PKG_CONFIG_PATH=$MUMBLE_PREFIX/lib/pkgconfig
gcc data.o appimagetool.o ../elf.c ../getsection.c -DENABLE_BINRELOC ../binreloc.c ${MUMBLE_PREFIX}/lib/libsquashfuse.a ${MUMBLE_PREFIX}/lib/libfuseprivate.a -Wl,-Bdynamic -lfuse -lpthread $(pkg-config --cflags glib-2.0) $(pkg-config --libs glib-2.0) -lz -Wl,-Bdynamic -o appimagetool

# AppRun
gcc ../AppRun.c -o AppRun
