:: Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

:: Dereference the C:\MumbleBuild\latest-1.3.x-win64-static junction point.
for /F "skip=9 tokens=3" %%M IN ('fsutil reparsepoint query c:\MumbleBuild\latest-1.3.x-win64-static') DO ^
IF NOT DEFINED MUMBLE_BUILDENV_DIR (SET MUMBLE_BUILDENV_DIR=%%M)

for /F %%G IN ('%MUMBLE_BUILDENV_DIR%\mumble-releng\tools\mumble-version.py') DO SET mumblebuildversion=%%G

call %MUMBLE_BUILDENV_DIR%\prep.cmd
if errorlevel 1 exit /b errorlevel

echo Build mumble
if "%MUMBLE_BUILD_TYPE%" == "Release" (
	qmake CONFIG+="release static symbols packaged no-g15 no-asio" DEFINES+="MUMBLE_VERSION=%mumblebuildversion%" -recursive
) else (
	qmake CONFIG+="release static symbols packaged no-g15 no-asio" DEFINES+="MUMBLE_VERSION=%mumblebuildversion% SNAPSHOT_BUILD=1" -recursive
)
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel

echo Build installer
SET MumbleNoMergeModule=1
SET MumbleDebugToolsDir=C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\Remote Debugger\x64
SET MumbleNoG15=1
SET MumbleNoSSE2=1
SET MumbleSourceDir=%cd%
cd scripts
call mkini-win32.bat
if errorlevel 1 exit /b errorlevel
cd ..\installer
if errorlevel 1 exit /b errorlevel
msbuild  /p:Configuration=Release;Platform=x64 MumbleInstall.sln /t:Clean,Build
if errorlevel 1 exit /b errorlevel
perl build_installer.pl
if errorlevel 1 exit /b errorlevel
cd bin\x64\Release
rename Mumble.msi "mumble-%mumblebuildversion%.winx64.msi"
if errorlevel 1 exit /b errorlevel

cd ..\..\..\..

if not "%MUMBLE_SKIP_INTERNAL_SIGNING%" == "1" (
	echo Adding build machine's signature to installer
	signtool sign /sm /a "installer/bin/x64/Release/mumble-%mumblebuildversion%.winx64.msi"
	if errorlevel 1 exit /b errorlevel
)

"%MUMBLE_BUILDENV_DIR%\mumble-releng\tools\collect_symbols.py" collect --version "%mumblebuildversion%" --buildtype "%MUMBLE_BUILD_TYPE%" --product "Mumble" --arch "%MUMBLE_BUILD_ARCH%" release\ symbols.7z
if errorlevel 1 exit /b errorlevel
