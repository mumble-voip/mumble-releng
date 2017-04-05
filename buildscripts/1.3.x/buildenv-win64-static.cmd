:: Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

@echo off

cd buildenv\1.3.x\win64-static

setlocal enabledelayedexpansion
for /f "delims=" %%I in ('setup.cmd /noninteractive') do set SETUP_OUTPUT=!SETUP_OUTPUT! %%I
set SETUP_OUTPUT=%SETUP_OUTPUT:~1%
setlocal disabledelayedexpansion

if not exist "%SETUP_OUTPUT%" (
	echo %SETUP_OUTPUT%
	exit /b 1
)

set BUILDENV_DIR=%SETUP_OUTPUT%
set CYGWIN_DIR=%BUILDENV_DIR%\cygwin
set BUILDENV_BUILD_DIR=%BUILDENV_DIR%.build
cd ..\..\..

for /f "delims=" %%I in ('%CYGWIN_DIR%\bin\cygpath.exe -u "%cd%"') do set PWD_CYGWIN=%%I
call %BUILDENV_DIR%\prep.cmd
%CYGWIN_DIR%\bin\bash.exe -c "source /etc/profile && cd \"%PWD_CYGWIN%\" && bash -ex buildscripts/1.3.x/buildenv-win64-static.bash"
if errorlevel 1 exit /b %errorlevel%
