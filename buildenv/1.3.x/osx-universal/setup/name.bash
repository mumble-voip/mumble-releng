#!/bin/bash
# Copyright 2014-2015 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

COUNT=$(git rev-list HEAD --count)
NAME=$(git log -n 1 --date=short --pretty="format:osx-universal-1.2.x-%ad-%h-${COUNT}")
if [ ! -z "$(git status --porcelain)" ]; then
	NAME="${NAME}~dirty"
fi
echo ${NAME}