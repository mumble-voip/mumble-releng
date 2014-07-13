#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

echo "The win64-static build environment is maintained "
echo "in the same directory as the win32-static build "
echo "environment."
echo
echo "I will automatically change to the win32-static directory "
echo "and call the win32-static 'build-all.bash' to initiate "
echo "the win64-static build."

cd ../win32-static
./build-all.bash