#!/bin/bash
set -e
SHA1="90b46f973930c27eb8586387de5dfbc2af04d3ed"
curl -L "http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.15.tar.gz/from/http://cdn.mysql.com/" > mysql-5.6.15.tar.gz
if [ "$(sha1sum mysql-5.6.15.tar.gz | cut -b -40)" != "${SHA1}" ]; then
	echo mysql checksum mismatch
	exit
fi
tar -zxf mysql-5.6.15.tar.gz
cd mysql-5.6.15
cmake -DCMAKE_INSTALL_PREFIX=${MUMBLE_PREFIX} -DINSTALL_LAYOUT=RPM -DWITH_EMBEDDED_SERVER=OFF -DWITH_SERVER=OFF -DWITH_SSL=yes -DWITH_LIBEDIT=yes -DWITH_ZLIB=system -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
make -j4
make install
