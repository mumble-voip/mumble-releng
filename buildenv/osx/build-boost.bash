#!/bin/bash
SHA1="cef9a0cc7084b1d639e06cd3bc34e4251524c840"
curl -L -O "http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2"
if [ "$(shasum -a 1 boost_1_55_0.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo boost checksum mismatch
	exit
fi
tar -jxf boost_1_55_0.tar.bz2
rm -rf $MUMBLE_PREFIX/include/boost_1_55_0
cd boost_1_55_0
./bootstrap.sh --prefix=${MUMBLE_PREFIX} --without-libraries=atomic,chrono,coroutine,context,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,log,math,mpi,program_options,python,random,regex,serialization,signals,system,test,thread,timer,wave
./b2 install
