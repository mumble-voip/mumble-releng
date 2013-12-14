#!/bin/bash
SHA1="f07716c470603729a55b70f5af68f4a6807097eb"
curl -O "http://www.portaudio.com/archives/pa_stable_v19_20111121.tgz"
if [ "$(shasum -a 1 pa_stable_v19_20111121.tgz | cut -b -40)" != "${SHA1}" ]; then
	echo portaudio checksum mismatch
	exit
fi

tar -zxf pa_stable_v19_20111121.tgz
cd portaudio
./configure --prefix=$MUMBLE_PREFIX --disable-shared --enable-static --enable-mac-universal
make
make install
