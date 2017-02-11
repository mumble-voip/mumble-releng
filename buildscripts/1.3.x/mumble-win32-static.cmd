:: Copyright 2014-2015 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

:: Dereference the C:\MumbleBuild\latest-1.3.x junction point.
for /F "skip=9 tokens=3" %%M IN ('fsutil reparsepoint query c:\MumbleBuild\latest-1.3.x') DO ^
IF NOT DEFINED MUMBLE_BUILDENV_DIR (SET MUMBLE_BUILDENV_DIR=%%M)

IF NOT DEFINED MUMBLE_NMAKE (SET MUMBLE_NMAKE=nmake)

for /F %%G IN ('python %MUMBLE_BUILDENV_DIR%\mumble-releng\tools\mumble-version.py') DO SET mumblebuildversion=%%G

call %MUMBLE_BUILDENV_DIR%\prep.cmd
if errorlevel 1 exit /b %errorlevel%

:: Prep switches echo off, reenable it
@echo on

echo Build mumble
if "%MUMBLE_BUILD_TYPE%" == "Release" (
	qmake CONFIG+="release static symbols packaged %MUMBLE_EXTRA_QMAKE_CONFIG_FLAGS%" DEFINES+="MUMBLE_VERSION=%mumblebuildversion%" -recursive
) else (
	qmake CONFIG+="release static symbols packaged %MUMBLE_EXTRA_QMAKE_CONFIG_FLAGS%" DEFINES+="MUMBLE_VERSION=%mumblebuildversion% SNAPSHOT_BUILD=1" -recursive
)
if errorlevel 1 exit /b %errorlevel%
%MUMBLE_NMAKE% release
if errorlevel 1 exit /b %errorlevel%

echo Build SSE2 versions of opus
cd 3rdparty\opus-build
%MUMBLE_NMAKE% clean
if errorlevel 1 exit /b %errorlevel%
qmake -recursive CONFIG+=sse2
if errorlevel 1 exit /b %errorlevel%
%MUMBLE_NMAKE% release
if errorlevel 1 exit /b %errorlevel%
cd ..\..

echo Build SSE2 versions of celt 0.11.0
cd 3rdparty\celt-0.11.0-build
%MUMBLE_NMAKE% clean
if errorlevel 1 exit /b %errorlevel%
qmake -recursive CONFIG+=sse2
if errorlevel 1 exit /b %errorlevel%
%MUMBLE_NMAKE% release
if errorlevel 1 exit /b %errorlevel%
cd ..\..

echo Build SSE2 versions of celt 0.7.0
cd 3rdparty\celt-0.7.0-build
%MUMBLE_NMAKE% clean
if errorlevel 1 exit /b %errorlevel%
qmake -recursive CONFIG+=sse2
if errorlevel 1 exit /b %errorlevel%
%MUMBLE_NMAKE% release
if errorlevel 1 exit /b %errorlevel%
cd ..\..

if "%MUMBLE_DO_PLUGIN_REPLACEMENT" == "1" (
	echo Perform plugin replacement
	python "%MUMBLE_PREFIX%\mumble-releng\tools\plugin_replacement.py" --version "%mumblebuildversion%" --repo . release\plugins
)
if errorlevel 1 exit /b %errorlevel%

echo Build installer
SET MumbleNoMergeModule=1
SET MumbleDebugToolsDir=C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Remote Debugger\x86
SET MumbleSourceDir=%cd%
SET MumbleVersionSubDir=%mumblebuildversion%
cd scripts
call mkini-win32.bat
if errorlevel 1 exit /b %errorlevel%
cd ..\installer
if errorlevel 1 exit /b %errorlevel%
msbuild  /p:Configuration=Release;Platform=x86 MumbleInstall.sln /t:Clean,Build
if errorlevel 1 exit /b %errorlevel%
perl build_installer.pl
if errorlevel 1 exit /b %errorlevel%
cd bin\Release
rename Mumble.msi "mumble-%mumblebuildversion%.msi"
if errorlevel 1 exit /b %errorlevel%

cd ..\..\..

if not "%MUMBLE_SKIP_INTERNAL_SIGNING%" == "1" (
	echo Adding build machine's signature to installer
	signtool sign /sm /a "installer/bin/Release/mumble-%mumblebuildversion%.msi"
)
if errorlevel 1 exit /b %errorlevel%

if not "%MUMBLE_SKIP_COLLECT_SYMBOLS%" == "1" (
	python "%MUMBLE_BUILDENV_DIR%\mumble-releng\tools\collect_symbols.py" collect --version "%mumblebuildversion%" --buildtype "%MUMBLE_BUILD_TYPE%" --product "Mumble %MUMBLE_BUILD_ARCH%" release\ symbols.7z
)
if errorlevel 1 exit /b %errorlevel%
