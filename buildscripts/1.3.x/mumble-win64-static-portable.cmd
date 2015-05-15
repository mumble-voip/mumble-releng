:: Copyright 2014-2015 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.

for /F "skip=9 tokens=3" %%M IN ('fsutil reparsepoint query c:\MumbleBuild\latest-1.3.x-win64-static') DO ^
IF NOT DEFINED MUMBLE_BUILDENV_DIR (SET MUMBLE_BUILDENV_DIR=%%M)

for /F %%G IN ('%MUMBLE_BUILDENV_DIR%\mumble-releng\tools\mumble-version.py') DO SET mumblebuildversion=%%G

call %MUMBLE_BUILDENV_DIR%\prep.cmd
if errorlevel 1 exit /b errorlevel

echo Build mumble
if "%MUMBLE_BUILD_TYPE%" == "Release" (
	qmake CONFIG+="release static symbols packaged no-g15 no-asio no-elevation no-server" DEFINES+="MUMBLE_VERSION=%mumblebuildversion%" -recursive
) else (
	qmake CONFIG+="release static symbols packaged no-g15 no-asio no-elevation no-server" DEFINES+="MUMBLE_VERSION=%mumblebuildversion% SNAPSHOT_BUILD=1" -recursive
)
if errorlevel 1 exit /b errorlevel
jom release
if errorlevel 1 exit /b errorlevel

set zipdir=mumble-%mumblebuildversion%.portable.winx64
set zipfile=%zipdir%.zip
mkdir mumble-%mumblebuildversion%.portable.winx64
if errorlevel 1 exit /b errorlevel

copy release\*.exe %zipdir%\
if errorlevel 1 exit /b errorlevel
copy release\*.dll %zipdir%\
if errorlevel 1 exit /b errorlevel
mkdir %zipdir%\plugins
if errorlevel 1 exit /b errorlevel
copy release\plugins\*.dll %zipdir%\plugins\
if errorlevel 1 exit /b errorlevel

copy "C:\Program Files (x86)\Windows Kits\8.1\Redist\D3D\x64\d3dcompiler_47.dll" %zipdir%\
if errorlevel 1 exit /b errorlevel
copy "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x64\Microsoft.VC120.CRT\msvcp120.dll" %zipdir%\
if errorlevel 1 exit /b errorlevel
copy "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x64\Microsoft.VC120.CRT\msvcr120.dll" %zipdir%\
if errorlevel 1 exit /b errorlevel

"C:\Program Files\7-Zip\7z.exe" a %zipfile% %zipdir%

"%MUMBLE_BUILDENV_DIR%\mumble-releng\tools\collect_symbols.py" collect --version "%mumblebuildversion%" --buildtype "%MUMBLE_BUILD_TYPE%" --product "Mumble %MUMBLE_BUILD_ARCH% Portable" release\ symbols.7z
if errorlevel 1 exit /b errorlevel
