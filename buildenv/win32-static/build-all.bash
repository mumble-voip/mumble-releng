#!/bin/bash

./build-boost.bash
./build-openssl.bash
./build-protobuf.bash

./build-libogg.bash
./build-libvorbis.bash
./build-libflac.bash
./build-libsndfile.bash
./msvcify-libsndfile.bash

./install-cmake-binary.bash
./build-mariadb-client.bash

./build-libmcpp.bash
./build-bzip2.bash
./build-berkeleydb.bash
./build-expat.bash
./build-zeroc-ice.bash