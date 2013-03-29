#!/bin/bash
set -e
SHA1="ec5d20f1ee52ae765b9286e9d7951dcfc9548607"
curl -L "http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.10.tar.gz/from/http://cdn.mysql.com/" > mysql-5.6.10.tar.gz
if [ "$(sha1sum openssl-1.0.0k.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo openssl checksum mismatch
	exit
fi
tar -zxf mysql-5.6.10.tar.gz
cd mysql-5.6.10
patch -p1 < ../patches/mysql-cmake-shared-openssl.patch
cmake -DCMAKE_INSTALL_PREFIX=${MUMBLE_PREFIX} -DINSTALL_LAYOUT=RPM -DWITH_EMBEDDED_SERVER=OFF -DWITH_SERVER=OFF -DWITH_SSL=yes -DWITH_LIBEDIT=yes -DWITH_SHARED_OPENSSL=yes -DWITH_ZLIB=system -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
make -j4
make install
