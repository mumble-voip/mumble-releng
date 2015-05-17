:: Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

:: setup.cmd sets up a new Mumble build environment
:: in the user's home directory (%USERPROFILE%).
::
:: It calls the script setup\name.cmd, which attempts
:: to use a git binary in the user's %PATH% to determine
:: a unique name for the build environment.
::
:: For example, on a builder, the build environment
:: would be installed in a directory such as:
:: C:\Users\builder\MumbleBuild-2013-08-25-3dc1638

@echo off

set CYGWIN=nodosfilewarning

:: Check that git is in the user's path.
where git.exe 1>NUL 2>NUL
if not "%errorlevel%"=="0" (
	echo.
	echo Unable to find git in your PATH.
	echo How did you check out this repository?!
	exit /b
)

:: Get the basename of the build environment.
if "%WANT_WIN64_BUILDENV%" == "1" (
	if "%WANT_DEBUG_BUILDENV%" == "1" (
		for /f %%I in ('setup\name64-debug.cmd') do set NAME=%%I
	)
	if "%WANT_NO_LTCG%" == "1" (
		for /f %%I in ('setup\name64-no-ltcg.cmd') do set NAME=%%I
	)
	if not defined NAME (
		for /f %%I in ('setup\name64.cmd') do set NAME=%%I
	)
) else (
	if "%WANT_DEBUG_BUILDENV%" == "1" (
		for /f %%I in ('setup\name-debug.cmd') do set NAME=%%I
	)
	if "%WANT_NO_LTCG%" == "1" (
		for /f %%I in ('setup\name-no-ltcg.cmd') do set NAME=%%I
	)
	if not defined NAME (
		for /f %%I in ('setup\name.cmd') do set NAME=%%I
	)
)

:: Set the absolute path of the build env target.
set MUMBLE_PREFIX=C:\MumbleBuild\%NAME%
set MUMBLE_PREFIX_BUILD=%MUMBLE_PREFIX%.build

if not exist "C:\MumbleBuild" (
	echo.
	echo The C:\MumbleBuild directory does not exist. Please create it, and
	echo make sure your current user has full access to it.
	echo.
	echo The easiest way to do this is to create a junction from C:\MumbleBuild
	echo into your user's home directory.
	echo.
	echo Open a admin command prompt [Ctrl-X followed by A on Win 8] and ensure
	echo you're at the root of C:, and run the following set of commands:
	echo.
	echo   "c:\> mkdir %%USERPROFILE%%\MumbleBuild"
	echo   "c:\> mklink /j MumbleBuild %%USERPROFILE%%\MumbleBuild"
	echo.
	echo Anything that allows you to write to c:\MumbleBuild works, though.
	echo [Including mounting a directory from another partition in C:\MumbleBuild]
	echo.
	if not "%1"=="/noninteractive" (
		pause
	)
	exit /b
)

if "%1"=="/force" goto install
if "%2"=="/force" goto install
if exist %MUMBLE_PREFIX% (
	echo.
	echo The target '%MUMBLE_PREFIX%' already exists; will not forcibly overwrite.
	echo.
	echo Re-run with the /force parameter from a command prompt to forcefully overwrite the
	echo existing build environment.
	echo.
	if not "%1"=="/noninteractive" (
		pause
	)
	exit /b
)

:: Copy all the needed files and create .lnks
:: for easily launching the build environment
:: command prompts.
:install
if not exist %MUMBLE_PREFIX% ( mkdir %MUMBLE_PREFIX% >NUL )
if not exist %MUMBLE_PREFIX_BUILD% ( mkdir %MUMBLE_PREFIX_BUILD% >NUL )
copy /Y setup\env %MUMBLE_PREFIX% >NUL
copy /Y setup\prep.cmd %MUMBLE_PREFIX% >NUL
copy /Y setup\cygwin.cmd %MUMBLE_PREFIX% >NUL
wscript setup\mklinks.wsf %MUMBLE_PREFIX% >NUL

:: Clone this revision of the mumble-releng repo
:: into the build environment.
for /f "delims=" %%I in ('git rev-parse --show-toplevel') do set MUMBLE_RELENG=%%I

set GIT_TARGET=%MUMBLE_PREFIX%\mumble-releng
if exist %GIT_TARGET% ( rd /s /q %GIT_TARGET% )
git clone --recursive "%MUMBLE_RELENG%" "%GIT_TARGET%" >NUL 2>NUL

if not "%1"=="/noninteractive" (
	echo.
	echo Build environment successfully created.
	echo Launching Windows Explorer in %MUMBLE_PREFIX%.
	explorer %MUMBLE_PREFIX%
	pause
) else (
	echo %MUMBLE_PREFIX%
)
