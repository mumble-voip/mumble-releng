:: install-cygwin-deps.cmd
:: Install Cygwin dependencies for the Mumble build environment.
::
:: This script expects a Cygwin setup.exe in the form of
:: either "setup-x86.exe" or "setup-x86_64.exe" to be present
:: next to it to perform its duties.

TITLE Install Cygwin Dependencies

@echo off
SET filename="" 
IF EXIST %cd%setup-x86.exe (
	SET filename="setup-x86.exe" 
    goto install
) else (
	IF EXIST %cd%setup-x86_64.exe (
		SET filename="setup-x86_64.exe" 
		goto install
	) else (
		goto error
	)
)

:error

echo.
echo No setup-x86 or setup-x86_64.exe found in the current directory.
echo.
pause
exit /b

:install

@echo on

:: This list of packages should be kept in sync with
:: the ones document in the build env's README file.
%filename% -q -P bzip2,ca-certificates,curl,diffstat,diffutils,^
dos2unix,file,findutils,git,grep,gzip,less,make,man,mingw-binutils,^
mingw-gcc-core,mingw-gcc-g++,mingw-pthreads,mingw-runtime,mingw-w32api,^
openssh,patch,patchutils,perl,perl-Error,perl_vendor,pkg-config,sed,tar,^
unzip,util-linux,vim,which,xz,zlib0

@echo off

echo.
echo Done.
echo.
pause
