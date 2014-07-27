:: Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

:: Dereference the C:\MumbleBuild\latest-1.3.x junction point.
for /F "skip=9 tokens=3" %%M IN ('fsutil reparsepoint query c:\MumbleBuild\latest-1.3.x') DO ^
IF NOT DEFINED MUMBLE_BUILDENV_DIR (SET MUMBLE_BUILDENV_DIR=%%M)

for /F %%G IN ('%MUMBLE_BUILDENV_DIR%\mumble-releng\tools\mumble-version.py') DO SET mumblebuildversion=%%G

call %MUMBLE_BUILDENV_DIR%\prep.cmd
if errorlevel 1 exit /b errorlevel

echo Build mumble
if "%MUMBLE_BUILD_TYPE%" == "Release" (
	qmake CONFIG+="release static symbols packaged" DEFINES+="MUMBLE_VERSION=%mumblebuildversion%" -recursive
) else (
	qmake CONFIG+="release static symbols packaged" DEFINES+="MUMBLE_VERSION=%mumblebuildversion% SNAPSHOT_BUILD=1" -recursive
)
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel

echo Build SSE2 versions of opus
cd opus-build
nmake clean
if errorlevel 1 exit /b errorlevel
qmake -recursive CONFIG+=sse2
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel
cd ..

echo Build SSE2 versions of celt 0.11.0
cd celt-0.11.0-build
nmake clean
if errorlevel 1 exit /b errorlevel
qmake -recursive CONFIG+=sse2
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel
cd ..

echo Build SSE2 versions of celt 0.7.0
cd celt-0.7.0-build
nmake clean
if errorlevel 1 exit /b errorlevel
qmake -recursive CONFIG+=sse2
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel
cd ..

if "%MUMBLE_DO_PLUGIN_REPLACEMENT" == "1" (
	echo Perform plugin replacement
	"%MUMBLE_PREFIX%\mumble-releng\tools\plugin_replacement.py" --version "%mumblebuildversion%" --repo . release\plugins
)

echo Build installer
SET MumbleNoMergeModule=1
SET MumbleDebugToolsDir=C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE
SET MumbleSourceDir=%cd%
cd scripts
call mkini-win32.bat
if errorlevel 1 exit /b errorlevel
cd ..\installer
if errorlevel 1 exit /b errorlevel
msbuild  /p:Configuration=Release;Platform=x86 MumbleInstall.sln /t:Clean,Build
if errorlevel 1 exit /b errorlevel
perl build_installer.pl
if errorlevel 1 exit /b errorlevel
cd bin\Release
rename Mumble.msi "mumble-%mumblebuildversion%.msi"
if errorlevel 1 exit /b errorlevel

cd ..\..\..

if not "%MUMBLE_SKIP_INTERNAL_SIGNING%" == "1" (
	echo Adding build machine's signature to installer
	signtool sign /sm /a "installer/bin/Release/mumble-%mumblebuildversion%.msi"
	if errorlevel 1 exit /b errorlevel
)

"%MUMBLE_BUILDENV_DIR%\mumble-releng\tools\collect_symbols.py" collect --version "%mumblebuildversion%" --buildtype "%MUMBLE_BUILD_TYPE%" --product "Mumble" release\ symbols.7z
if errorlevel 1 exit /b errorlevel
