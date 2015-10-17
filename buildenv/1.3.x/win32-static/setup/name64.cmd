:: Copyright 2013-2015 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

@echo off
for /f "delims=" %%i in ('git rev-list HEAD --count') do set count=%%i
git log -n 1 --date=short --pretty="format:win64-static-1.3.x-%%ad-%%h-%count%"