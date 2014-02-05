#!/bin/bash -e

./install-nasm-binary.bash
./install-cmake-binary.bash

./build-boost.bash
./build-openssl.bash
./build-protobuf.bash

./build-libogg.bash
./build-libvorbis.bash
./build-libflac.bash
./build-libsndfile.bash
./combine-libsndfile-libs.bash

./build-bonjour.bash

./build-zlib.bash

./build-mariadb-client.bash

./build-qt4.bash

./build-libmcpp.bash
./build-bzip2.bash
./build-berkeleydb.bash
./build-expat.bash
./build-zeroc-ice.bash
