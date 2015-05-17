:: Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
:: Use of this source code is governed by a BSD-style license that
:: can be found in the LICENSE file in the source tree or at
:: <http://mumble.info/mumble-releng/LICENSE>.
@echo off

SET MUMBLE_PREFIX=%~dp0
IF %MUMBLE_PREFIX:~-1%==\ SET MUMBLE_PREFIX=%MUMBLE_PREFIX:~0,-1%
SET MUMBLE_PREFIX_BUILD=%MUMBLE_PREFIX%.build

SET MUMBLE_BUILD_CONFIGURATION=Release
SET MUMBLE_BUILD_USE_LTCG=1
SET VSVER=12.0
SET XPCOMPAT=1
SET LIB=
SET ARCH=x86

:: Automatic detection of win32-static/win64-static.
:: If you want full control of these options, feel
:: free to delete this snippet in your own build
:: environment.
echo %MUMBLE_PREFIX% | findstr /C:"win64-static" 1>nul
if not errorlevel 1 (
	SET XPCOMPAT=0
	SET ARCH=amd64
)

:: Automatic detection of debug mode.
:: If you want full control of these options, feel
:: free to delete this snippet in your own build
:: environment.
echo %MUMBLE_PREFIX% | findstr /C:"debug" 1>nul
if not errorlevel 1 (
	SET MUMBLE_BUILD_CONFIGURATION=Debug
	SET MUMBLE_BUILD_USE_LTCG=0
)

:: Automatic detection of no-ltcg mode.
:: If you want full control of these options, feel
:: free to delete this snippet in your own build
:: environment.
echo %MUMBLE_PREFIX% | findstr /C:"no-ltcg" 1>nul
if not errorlevel 1 (
	SET MUMBLE_BUILD_USE_LTCG=0
)

set MUMBLE_OPENSSL_PREFIX=%MUMBLE_PREFIX%\OpenSSL
set MUMBLE_SNDFILE_PREFIX=%MUMBLE_PREFIX%\sndfile
set MUMBLE_PROTOBUF_PREFIX=%MUMBLE_PREFIX%\protobuf
SET MUMBLE_QT_PREFIX=%MUMBLE_PREFIX%\Qt5
SET MUMBLE_ICE_PREFIX=%MUMBLE_PREFIX%\ZeroC-Ice
set MUMBLE_JOM_PREFIX=%MUMBLE_PREFIX%\jom
set MUMBLE_PYTHON_PREFIX=%MUMBLE_PREFIX%\python
set MUMBLE_PERL_PREFIX=%MUMBLE_PREFIX%\perl
set MUMBLE_NASM_PREFIX=%MUMBLE_PREFIX%\nasm

:: We want Cygwin's /usr/bin and /usr/local/bin directories
:: to come directly after the the PATH additions we prepend
:: to the PATH in this script.
::
:: We have a very strict PATH ordering we need to follow to
:: get consistent behavior on all systems:
::
::  1. MSVS toolchain and our own tools (mainly because link.exe
::     clashes with /usr/bin/link in Cygwin).
::
::  2. When in Cygwin, we prefer /usr/bin and /usr/local/bin over
::     %WINDIR%\System32. Bash scripts will break horribly if
::     'sort' and 'find' are Windows's variants.
::
::  3. The rest of the systems original %PATH% (including System32).
::
:: To reach that goal, we insert a fake entry in the PATH that we
:: can replace with something useful once we enter a Cygwin shell,
:: which happens via the 'env' script.
::
:: We insert it at this point in the code, because the dx_setenv.cmd
:: script and MSVS's vcvarsall.bat both prepend to the current PATH.
:: Our own PATH additions further down in this file also prepend to
:: PATH. So, to ensure Cygwin's entires come *after* all of those,
:: we have to put it front here.
SET PATH=--cygwin--;%PATH%

IF DEFINED %PROGRAMFILES(X86)% (
  GOTO amd64host
) ELSE (
  GOTO x86host
)

:amd64host
SET PROGPATH=%PROGRAMFILES(X86)%
GOTO VersionPicker

:x86host
SET PROGPATH=%PROGRAMFILES%
GOTO VersionPicker

:VersionPicker
IF %VSVER%==10.0 GOTO VS2010
IF %VSVER%==12.0 GOTO VS2013

:VSUNKNOWN
ECHO.
ECHO Unknown version of Visual Studio detected. (VSVER is set to `%VSVER%`)
ECHO Unable to initialize build environment. Aborting...
ECHO.
PAUSE
EXIT

:VS2010
TITLE MumbleBuild MSVS2010 (v100)
SET MUMBLE_VSTOOLSET=v100
CALL "%DXSDK_DIR%\Utilities\bin\dx_setenv.cmd" %ARCH% >NUL
CALL "%PROGPATH%\Microsoft Visual Studio %VSVER%\VC\vcvarsall.bat" %ARCH% >NUL
GOTO FINALIZE

:VS2013
IF %XPCOMPAT%==1 GOTO VS2013XP
TITLE MumbleBuild MSVC2013 (v120)
SET MUMBLE_VSTOOLSET=v120
CALL "%DXSDK_DIR%\Utilities\bin\dx_setenv.cmd" %ARCH% >NUL
CALL "%PROGPATH%\Microsoft Visual Studio %VSVER%\VC\vcvarsall.bat" %ARCH% >NUL
GOTO FINALIZE

:VS2013XP
TITLE MumbleBuild MSVS2013 (v120_xp)
SET MUMBLE_VSTOOLSET=v120_xp
CALL "%PROGPATH%\Microsoft Visual Studio %VSVER%\VC\vcvarsall.bat" %ARCH% >NUL
:: Set up the environment such that using cl.exe and friends
:: from the command line will work as if we were using the "v120_xp"
:: toolset in Visual Studio.
::
:: Technically, this uses a specially re-packaged Windows 7 SDK
:: called "v7.1A", and sets a preprocessor define, _USING_V110_SDK71_
:: (it's called V110 for both v110_xp and v120_xp).
set INCLUDE=%PROGPATH%\Microsoft SDKs\Windows\v7.1A\Include;%INCLUDE%
set PATH=%PROGPATH%\Microsoft SDKs\Windows\v7.1A\Bin;%PATH%
set LIB=%PROGPATH%\Microsoft SDKs\Windows\v7.1A\Lib;%LIB%
set CL=/D_USING_V110_SDK71_ %CL%
:: We call dx_setenv after vcvarsall to avoid accidently using the
:: DirectX bundled with MSVC2013's Windows 8 SDK.
::
:: When building using the v120_xp toolset, the latest supported
:: Windows SDK is the Windows v7.1A SDK, which is a specially
:: re-packaged version of the Windows 7 SDK meant for use in the
:: XP compatibility toolsets for Visual Studio 2012 and 2013
:: (i.e. v120_xp).
::
:: Since the Windows 8 SDK is unsupported for Windows XP use,
:: the SDK-bundled DirectX is probably also off-limits. To ensure
:: we're using the non-bundled "June 2010" variant, we call its
:: dx_setenv.cmd *after* vcvarsall, to ensure the bin, lib and include
:: environment variables come before the ones from the Windows 8 SDK.
::
:: Additionally, we also call it after setting up the INCLUDE, PATH, LIB
:: and CL environment variables to use the Windows v7.1A SDK (for XP
:: compatibility) to ensure that the DirextX headers from the Windows
:: v7.1A SDK does not interfere with the June 2010 variant.
CALL "%DXSDK_DIR%\Utilities\bin\dx_setenv.cmd" %ARCH% >NUL
GOTO FINALIZE

:FINALIZE

:: Clear out various Perl environment variables
:: that could confuse our bundled Perl.
SET PERL_JSON_BACKEND=
SET PERL_YAML_BACKEND=
SET PERL5LIB=
SET PERL5OPT=
SET PERL_MM_OPT=
SET PERL_MB_OPT=

SET PATH=%MUMBLE_PYTHON_PREFIX%;%PATH%
SET PATH=%MUMBLE_PERL_PREFIX%\perl\bin;%MUMBLE_PERL_PREFIX%\perl\site\bin;%PATH%
SET PATH=%MUMBLE_NASM_PREFIX%;%PATH%
SET PATH=%MUMBLE_QT_PREFIX%\bin;%PATH%
SET PATH=%MUMBLE_OPENSSL_PREFIX%\bin;%PATH%
SET PATH=%MUMBLE_JOM_PREFIX%\bin;%PATH%
SET PATH=%MUMBLE_PROTOBUF_PREFIX%\vsprojects\%MUMBLE_BUILD_CONFIGURATION%;%PATH%
if "%ARCH%" == "x86" SET PATH=%MUMBLE_ICE_PREFIX%\bin;%PATH%
if "%ARCH%" == "amd64" SET PATH=%MUMBLE_ICE_PREFIX%\bin\x64;%PATH%
cmd /V:ON /K %*
exit /b
