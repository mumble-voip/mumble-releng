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
for /f %%I in ('setup\name.cmd') do set NAME=%%I

:: Set the absolute path of the build env target.
set MUMBLE_PREFIX=%USERPROFILE%\%NAME%
set MUMBLE_PREFIX_BUILD=%MUMBLE_PREFIX%.build

if "%1"=="/force" goto install
if exist %MUMBLE_PREFIX% (
	echo.
	echo The target '%MUMBLE_PREFIX%' already exists; will not forcibly overwrite.
	echo.
	echo Re-run as 'setup /force' from a command prompt to forcefully overwrite the
	echo existing build environment.
	echo.
	pause
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
wscript setup\mklinks.wsf %NAME% >NUL

:: Clone this revision of the mumble-releng repo
:: into the build environment.
for /f %%I in ('git rev-parse --show-toplevel') do set MUMBLE_RELENG=%%I
set GIT_TARGET=%MUMBLE_PREFIX%\mumble-releng
if exist %GIT_TARGET% ( rd /s /q %GIT_TARGET% )
git clone %MUMBLE_RELENG% %GIT_TARGET%

echo.
echo Build environment successfully created.
echo Launching Windows Explorer in %MUMBLE_PREFIX%.
explorer %MUMBLE_PREFIX%

pause