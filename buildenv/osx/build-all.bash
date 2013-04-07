#!/bin/bash

# Mumble
./build-pkgconfig.bash
./build-openssl.bash
./build-libxar.bash
./build-qt.bash
./build-qt-icnsicon.bash
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