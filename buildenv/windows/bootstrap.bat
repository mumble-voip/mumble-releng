@echo off

echo ===============================================================================
echo =                                                                             =
echo = RUNNING THIS SCRIPT CAN SERIOUSLY MESS UP YOUR MACHINE. Only use on a       =
echo = clean system you are willing to break.                                      =
echo =                                                                             =
echo ===============================================================================
echo =                                                                             =
echo = This script bootstraps a mumble windows build environment. To achieve this  =
echo = it first installs msysgit, then checks out the mumble-releng repository so  =
echo = it can run the actual powershell setup script.                              =
echo =                                                                             =
echo ===============================================================================
echo.

rem Arch test
IF NOT EXIST "%PROGRAMFILES(X86)%" (GOTO wrongArch)

rem Windows version check
ver | find "6.1" > nul
if %errorLevel% == 0 goto goodVersion
ver | find "6.2" > nul
if %errorLevel% == 0 goto goodVersion
goto wrongVersion

:goodVersion

rem Check for admin priviledges
net session >nul 2>&1
if not %errorLevel% == 0 goto noAdmin


rem Give the user a chance to abort
timeout /T 10
echo.

echo Bootstrapping into C:\dev\
mkdir C:\dev\
copy /Y %0 C:\dev\bootstrap.bat
cd /d C:\dev\
if not %errorLevel% == 0 goto error

IF EXIST "C:\Program Files (x86)\Git\bin\git.exe" GOTO :skipInstall
IF EXIST "Git-1.8.0-preview20121022.exe" GOTO :skipDownload

echo Downloading msysgit http://msysgit.googlecode.com/files/Git-1.8.0-preview20121022.exe ...
powershell -Command "$wc = New-Object System.Net.WebClient; $wc.downloadFile('http://msysgit.googlecode.com/files/Git-1.8.0-preview20121022.exe', 'Git-1.8.0-preview20121022.exe')"
if not %errorLevel% == 0 goto error
echo Done

goto skipSkipDownload
:skipDownload
echo Downloading msysgit...skipped
:skipSkipDownload

echo Installing msysgit...
start /wait Git-1.8.0-preview20121022.exe /SILENT /SUPPRESSMSGBOXES /COMPONENTS="*icons" /LOG="msysgit-setup.log" /NOCANCEL /NORESTART
if not %errorLevel% == 0 goto error
echo Done

goto skipSkipInstall
:skipInstall
echo Installing msysgit...skipped
:skipSkipInstall

echo Cloning mumble-releng...
"C:\Program Files (x86)\Git\bin\git.exe" clone git://github.com/mumble-voip/mumble-releng.git
if not %errorLevel% == 0 goto error
echo Done

cd mumble-releng\buildenv\windows
echo Launching setup process...
powershell -ExecutionPolicy bypass -File ".\setup.ps1"
goto end

:wrongArch
echo This script was written for 64-Bit machines only
exit /b 1

:wrongVersion
echo This script was written for Windows 7 and newer only
exit /b 2

:noAdmin
echo Bootstrap requires administrator priviledges
exit /b 3

:error
echo Failed, aborting
exit /b 666

:end
exit /b %errorLevel%