:: Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

:: Transitions the Mumble prep.bat cmd.exe-based
:: build environment to a Cywin environment in 
:: Cygwin's bash shell.

@echo off

set MUMBLE_CYGWIN_ROOT_SOURCE=environment

:: First, check if we have a locally bootstrapped Cygwin
:: in %MUMBLE_PREFIX%, and use it if available.
if not defined MUMBLE_CYGWIN_ROOT (
	set MUMBLE_CYGWIN_ROOT_SOURCE=buildenv
	set MUMBLE_CYGWIN_ROOT=%MUMBLE_PREFIX%\cygwin
)

:: First, try to query the registry for a potential Cygwin
:: installation directory.
if not defined MUMBLE_CYGWIN_ROOT (
	for /f "tokens=2* delims= " %%a in ('reg query "HKCU\Software\Cygwin\Installations" 2^>nul') do set MUMBLE_CYGWIN_ROOT=%%b
	set MUMBLE_CYGWIN_ROOT_SOURCE=registry
)

:: HKCU\Software\Cygwin\Installations has a weird prefix on the install dir,
:: so strip it if it's there.
if "%MUMBLE_CYGWIN_ROOT:~0,4%" == "\??\" (
	set MUMBLE_CYGWIN_ROOT=%MUMBLE_CYGWIN_ROOT:~4%
)

:: The registry query worked. However, the directory we found might not be a real
:: Cygwin installation. It might just be an SDK (such as the Android SDK), or something
:: else that uses a cygwin1.dll. To determine if it is a proper Cygwin installation, we
:: check if /bin/bash.exe exists. If it doesn't, unset MUMBLE_CYGWIN_ROOT such
:: that the next check (the check below us) will fall back to using standard Cygwin
:: directories.
if defined MUMBLE_CYGWIN_ROOT (
	if not exist "%MUMBLE_CYGWIN_ROOT%\bin\bash.exe" (
		echo Discarding %MUMBLE_CYGWIN_ROOT_SOURCE% Cygwin root candidate from %MUMBLE_CYGWIN_ROOT%, bin\bash.exe not found.
		set MUMBLE_CYGWIN_ROOT=
		set MUMBLE_CYGWIN_ROOT_SOURCE=defaults
	)
)

:: If the registry query fails, or the directory doesn't exist,
:: try some of the most likely Cygwin directories, and set them
:: as MUMBLE_CYGWIN_ROOT if they exist.
if not defined MUMBLE_CYGWIN_ROOT (
	if exist "c:\cygwin" (
		set MUMBLE_CYGWIN_ROOT=c:\cygwin
	)
	if exist "c:\cygwin64" (
		set MUMBLE_CYGWIN_ROOT=c:\cygwin64
	)
)

:: If we still do not have a usable root, bail.
if not defined MUMBLE_CYGWIN_ROOT (
	echo Failed to find a usable Cygwin root. Please make sure you have a Cygwin installed.
	echo You can set MUMBLE_CYGWIN_ROOT to select a specific Cygwin.
	exit /b 1
)

echo Using Cygwin from: %MUMBLE_CYGWIN_ROOT% (found in %MUMBLE_CYGWIN_ROOT_SOURCE%, set MUMBLE_CYGWIN_ROOT to choose another)

for /f %%I in ('%MUMBLE_CYGWIN_ROOT%\bin\cygpath %MUMBLE_PREFIX%') do set BOOTSTRAP_CYGWIN_MUMBLE_PREFIX=%%I
%MUMBLE_CYGWIN_ROOT%\bin\bash.exe -c "source /etc/profile && source ${BOOTSTRAP_CYGWIN_MUMBLE_PREFIX}/env && cd ${MUMBLE_PREFIX} && bash"

