#!/usr/bin/env mumble-build
# Copyright 2013-2017 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

$target = $Args[0]
$url = $Args[1]
$sha256hash = $Args[2]

$client = New-Object System.Net.WebClient
$client.DownloadFile($url, $target)
$hash = Get-FileHash $target -Algorithm SHA256
if (($hash.Hash) -ne ($sha256hash)) {
	Remove-Item $target
	exit 1
}

exit 0
