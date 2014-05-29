@echo off

SET MUMBLE_PREFIX=%~dp0
IF %MUMBLE_PREFIX:~-1%==\ SET MUMBLE_PREFIX=%MUMBLE_PREFIX:~0,-1%
SET MUMBLE_PREFIX_BUILD=%MUMBLE_PREFIX%.build

SET VSVER=12.0
SET XPCOMPAT=1
SET LIB=

set MUMBLE_OPENSSL_PREFIX=%MUMBLE_PREFIX%\OpenSSL
set MUMBLE_SNDFILE_PREFIX=%MUMBLE_PREFIX%\sndfile
set MUMBLE_PROTOBUF_PREFIX=%MUMBLE_PREFIX%\protobuf
SET MUMBLE_QT_PREFIX=%MUMBLE_PREFIX%\Qt4.8
SET MUMBLE_ICE_PREFIX=%MUMBLE_PREFIX%\ZeroC-Ice

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
  GOTO amd64
) ELSE (
  GOTO x86
)

:amd64
SET PROGPATH=%PROGRAMFILES(X86)%
GOTO SDKVars

:x86
SET PROGPATH=%PROGRAMFILES%
GOTO SDKVars

:SDKVars
CALL "%PROGPATH%\Microsoft Visual Studio %VSVER%\VC\vcvarsall.bat" x86 >NUL

:: We call dx_setenv after vcvarsall to avoid accidently using the
:: DirectX bundled with MSVC2013's Windows 8 SDK.
::
:: When building using the v120_xp toolset, the latest supported
:: Windows SDK is the Windows v7.1A SDK, which is a specially
:: re-packaged version of the Windows 7 SDK meant for use in the
:: XP compatibility toolsets for Visual Studio 2012 and 2013
:: (i.e. v120_xp).
::
:: Since the Windows 8 SDK is unsupported, the SDK-bundled DirectX is probably
:: also off-limits. To ensure we're using the non-bundled "June 2010" variant,
:: we call its dx_setenv.cmd *after* vcvarsall, to ensure the bin, lib and include
:: environment variables come before the ones from the Windows 8 SDK. 
CALL "%DXSDK_DIR%\Utilities\bin\dx_setenv.cmd" x86 >NUL

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
GOTO FINALIZE

:VS2013
IF %XPCOMPAT%==1 GOTO VS2013XP
TITLE MumbleBuild MSVC2013 (v120)
SET MUMBLE_VSTOOLSET=v120
GOTO FINALIZE

:VS2013XP
TITLE MumbleBuild MSVS2013 (v120_xp)
SET MUMBLE_VSTOOLSET=v120_xp
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
GOTO FINALIZE

:FINALIZE
SET PATH=%MUMBLE_QT_PREFIX%\bin;%MUMBLE_OPENSSL_PREFIX%\bin;%MUMBLE_OPENSSL_PREFIX%\bin;%MUMBLE_PROTOBUF_PREFIX%\vsprojects\Release;%MUMBLE_ICE_PREFIX%\bin;%PATH%
cmd /V:ON /K %*
exit /b