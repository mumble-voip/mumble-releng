#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2"
expect_sha1 "boost_1_55_0.tar.bz2" "cef9a0cc7084b1d639e06cd3bc34e4251524c840"
expect_sha256 "boost_1_55_0.tar.bz2" "fff00023dd79486d444c8e29922f4072e1d451fc5a4d2b6075852ead7f2b7b52"

tar -jxf boost_1_55_0.tar.bz2
rm -rf ${MUMBLE_PREFIX}/include/boost_1_55_0
cd boost_1_55_0
./bootstrap.sh --prefix=${MUMBLE_PREFIX} --without-libraries=atomic,chrono,coroutine,context,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,log,math,mpi,program_options,python,random,regex,serialization,signals,system,test,thread,timer,wave
./b2 install
