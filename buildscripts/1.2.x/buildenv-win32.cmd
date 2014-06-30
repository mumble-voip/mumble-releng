:: Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

@echo off

:: First, try to query the registry for a potential Cygwin
:: installation directory.
for /f "tokens=2* delims= " %%a in ('reg query "HKCU\Software\Cygwin\Installations"') do set MUMBLE_CYGWIN_ROOT=%%b
:: Clear the output of reg.exe.
:: It write an error to stderr if it fails, and we seemingly
:: cannot redirect it within a "for in" block.
cls

:: If the registry query fails, try some of the most likely
:: Cygwin directories, and set them as MUMBLE_CYGWIN_ROOT
:: if they exist.
if not defined MUMBLE_CYGWIN_ROOT (
	if exist c:\cygwin (
		set MUMBLE_CYGWIN_ROOT=c:\cygwin
	)
	if exist c:\cygwin64 (
		set MUMBLE_CYGWIN_ROOT=c:\cygwin64
	)
)
:: HKCU\Software\Cygwin\Installations has a weird prefix on the install dir,
:: so strip it if it's there.
if "%MUMBLE_CYGWIN_ROOT:~0,4%" == "\??\" (
	set MUMBLE_CYGWIN_ROOT=%MUMBLE_CYGWIN_ROOT:~4%
)

cd buildenv\1.2.x\win32

setlocal enabledelayedexpansion
for /f "delims=" %%I in ('setup.cmd /noninteractive') do set SETUP_OUTPUT=!SETUP_OUTPUT! %%I
set SETUP_OUTPUT=%SETUP_OUTPUT:~1%
setlocal disabledelayedexpansion

if not exist "%SETUP_OUTPUT%" (
	echo %SETUP_OUTPUT%
	exit /b 1
)

set BUILDENV_DIR=%SETUP_OUTPUT%
set BUILDENV_DIR_BUILD=%BUILDENV_DIR%.build
cd ..\..\..

for /f "delims=" %%I in ('%MUMBLE_CYGWIN_ROOT%\bin\cygpath.exe -u "%cd%"') do set PWD_CYGWIN=%%I
cmd /k %BUILDENV_DIR%\prep.cmd %MUMBLE_CYGWIN_ROOT%\bin\bash.exe -c "source /etc/profile && cd \"%PWD_CYGWIN%\" && bash -ex buildscripts/1.2.x/buildenv-win32.bash"
if errorlevel 1 exit /b errorlevel
