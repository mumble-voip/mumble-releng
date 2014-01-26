#!/bin/bash

# Utils
./build-pkgconfig.bash
./build-libtoolbash
./build-autoconf.bash
./build-automake.bash
./build-xz.bash

# Mumble
./build-openssl.bash
./build-libxar.bash
./build-qt4.bash
./build-qt4-icnsicon.bash
./build-qt5.bash
./build-qt5-icnsicon.bash
./build-boost.bash
./build-libogg.bash
./build-libvorbis.bash
./build-libflac.bash
./build-libsndfile.bash
./build-protobuf.bash

# Murmur
./build-berkeleydb.bash
./build-libmcpp.bash
./build-zeroc-ice.bash
