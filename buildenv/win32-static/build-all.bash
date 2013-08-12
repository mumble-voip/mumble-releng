#!/bin/bash

./build-boost.bash
./build-openssl.bash
./build-protobuf.bash

./build-libogg.bash
./build-libvorbis.bash
./build-libflac.bash
./build-libsndfile.bash
./msvcify-libsndfile.bash

./build-libmcpp.bash