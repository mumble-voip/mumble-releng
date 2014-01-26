#!/bin/bash
set -e
SHA1="cef9a0cc7084b1d639e06cd3bc34e4251524c840"
curl -L -O "http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2"
if [ "$(sha1sum boost_1_55_0.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo boost checksum mismatch
	exit
fi
tar -jxf boost_1_55_0.tar.bz2
cd boost_1_55_0
./bootstrap.sh --without-libraries=atomic,chrono,context,coroutine,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,log,math,mpi,program_options,python,random,regex,serialization,signals,system,test,thread,timer,wave --prefix=${MUMBLE_PREFIX}
./b2 install
