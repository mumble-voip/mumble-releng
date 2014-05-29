#!/bin/bash -ex
SHA1="2136bc24fa35cdcbd00816fbbf312b727150256b"
curl -O "http://mirror.linux.org.au/linux/libs/security/linux-privs/libcap2/libcap-2.22.tar.bz2"
if [ "$(sha1sum libcap-2.22.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo libcap checksum mismatch
	exit
fi
tar -jxf libcap-2.22.tar.bz2
cd libcap-2.22/libcap
make LIBATTR=no FAKEROOT=${MUMBLE_PREFIX} prefix=
make LIBATTR=no FAKEROOT=${MUMBLE_PREFIX} prefix= install

