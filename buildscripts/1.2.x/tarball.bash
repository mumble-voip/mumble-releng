#!/bin/bash -ex
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source /MumbleBuild/latest-1.2.x/env
ver=$(python /MumbleBuild/latest-1.2.x/mumble-releng/tools/mumble-version.py)
chmod +x ./scripts/release.pl
./scripts/release.pl ${ver}
