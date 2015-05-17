:: Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

:: setup.cmd sets up a new Mumble build environment
:: in the user's home directory (%USERPROFILE%).
::
:: Since the win32-static and win64-static build
:: environments are maintained in a single directory,
:: this setup script simply sets a flag signalling
:: that we want a 64-bit build environment, and calls
:: win32-static's setup.cmd.

@echo off

set WANT_WIN64_BUILDENV=1
set WANT_NO_LTCG=1
set SETUP_DIR=%~dp0
cd %SETUP_DIR%\..\win32-static
setup.cmd %*
