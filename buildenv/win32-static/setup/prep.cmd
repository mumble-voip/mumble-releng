@echo off

SET MUMBLE_PREFIX=%~dp0
IF %MUMBLE_PREFIX:~-1%==\ SET MUMBLE_PREFIX=%MUMBLE_PREFIX:~0,-1%
SET MUMBLE_PREFIX_BUILD=%MUMBLE_PREFIX%.build

SET VSVER=10.0
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

CALL "%DXSDK_DIR%\Utilities\bin\dx_setenv.cmd" x86

IF DEFINED %PROGRAMFILES(X86)% (
  GOTO amd64
) ELSE (
  GOTO x86
)

:amd64
SET PROGPATH=%PROGRAMFILES(X86)%
GOTO Common

:x86
SET PROGPATH=%PROGRAMFILES%
GOTO Common

:Common
CALL "%PROGPATH%\Microsoft Visual Studio %VSVER%\VC\vcvarsall.bat" x86
SET PATH=%MUMBLE_QT_PREFIX%\bin;%MUMBLE_OPENSSL_PREFIX%\bin;%MUMBLE_OPENSSL_PREFIX%\bin;%MUMBLE_PROTOBUF_PREFIX%\vsprojects\Release;%MUMBLE_ICE_PREFIX%\bin;%PATH%
TITLE Mumble Development Environment

cmd /V:ON /K %*
exit /b