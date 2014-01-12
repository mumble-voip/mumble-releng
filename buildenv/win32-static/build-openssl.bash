#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.openssl.org/source/openssl-1.0.0l.tar.gz"
expect_sha1 "openssl-1.0.0l.tar.gz" "f7aeaa76a043ab9c1cd5899d09c696d98278e2d7"
expect_sha256 "openssl-1.0.0l.tar.gz" "2a072e67d9e3ae900548c43d7936305ba576025bd083d1e91ff14d68ded1fdec"

tar -zxf openssl-1.0.0l.tar.gz
cd openssl-1.0.0l

./Configure VC-WIN32 no-shared --prefix=$(cygpath -w "${MUMBLE_PREFIX}/OpenSSL")
cmd /c ms\\do_nasm

# The do_nasm script leaves a stale NUL file when called
# with cygwin perl. The file isn't obviously removable from
# explorer.exe because it's a reserved name.
# We'll be friendly and remove it here. :-)
rm -rf ./NUL

# Change /MT to /MD (MultiThreaded -> MultiThreadedDLL)
sed -i -e 's,/MT ,/MD ,g' ms/nt.mak

cmd /c set PATH="$(cygpath -w ${MUMBLE_PREFIX}/nasm);%PATH%" \&\& nmake -f ms\\nt.mak
cmd /c nmake -f ms\\nt.mak test
cmd /c nmake -f ms\\nt.mak install