:: Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

:: setup.cmd sets up a new Mumble build environment
:: in the user's home directory (%USERPROFILE%).

@echo off

set WANT_NO_LTCG=1
set SETUP_DIR=%~dp0
cd %SETUP_DIR%\..\win32-static
setup.cmd %*
