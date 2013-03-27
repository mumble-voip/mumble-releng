#!/bin/bash
set -e
SHA1="e6dd1b62ceed0a51add3dda6f3fc3ce0f636a7f3"
curl -L -O "http://downloads.sourceforge.net/project/boost/boost/1.53.0/boost_1_53_0.tar.bz2"
if [ "$(sha1sum boost_1_53_0.tar.bz2 | cut -b -40)" != "${SHA1}" ]; then
	echo boost checksum mismatch
	exit
fi
tar -jxf boost_1_53_0.tar.bz2
cd boost_1_53_0
./bootstrap.sh --without-libraries=atomic,chrono,context,date_time,exception,filesystem,graph,graph_parallel,iostreams,locale,math,mpi,program_options,python,random,regex,serialization,signals,system,test,thread,timer,wave --prefix=${MUMBLE_PREFIX}
./b2 install
