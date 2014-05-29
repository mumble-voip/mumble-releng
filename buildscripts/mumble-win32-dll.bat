:: Use 'git describe' output as the version.
for /F %%G IN ('git describe') DO SET mumblebuildversion=%%G

call c:\dev\prep.bat
if errorlevel 1 exit /b errorlevel

:: Copy winpaths_custom from the build env root.
copy c:\dev\winpaths_custom.pri .\

echo Build mumble
if "%MUMBLE_BUILD_TYPE%" == "Release" (
	make CONFIG-=sse2 CONFIG+=packaged DEFINES+="MUMBLE_VERSION=%mumblebuildversion%" -recursive
) else (
	qmake CONFIG-=sse2 CONFIG+=packaged DEFINES+="MUMBLE_VERSION=%mumblebuildversion% SNAPSHOT_BUILD=1" -recursive
)
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel

echo Build SSE2 versions of opus
cd opus-build
qmake -recursive
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel
cd ..

echo Build SSE2 versions of celt 0.11.0
cd celt-0.11.0-build
qmake -recursive
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel
cd ..

echo Build SSE2 versions of celt 0.7.0
cd celt-0.7.0-build
qmake -recursive
if errorlevel 1 exit /b errorlevel
nmake release
if errorlevel 1 exit /b errorlevel
cd ..

if "%MUMBLE_DO_PLUGIN_REPLACEMENT" == "1" (
	echo Perform plugin replacement
	"C:\dev\mumble-releng\tools\plugin_replacement.py" --version "%mumblebuildversion%" --repo . release\plugins
)

echo Build installer
SET MumbleNoMergeModuleDir=1
SET MumbleDebugToolsDir=C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE
SET MumbleZlibDir=C:\dev\zlib128-dll
SET MumbleSourceDir=%cd%
cd scripts
call mkini-win32.bat
if errorlevel 1 exit /b errorlevel
cd ..\installer
c:\cygwin\bin\sed -ri "s,</Include>,<?define RedistDirVC10 = \"C:\\\\Program Files (x86)\\\\Microsoft Visual Studio 10.0\\\\VC\\\\redist\\\\x86\\\\Microsoft.VC100.CRT\" ?></Include>,g" Settings.wxi
if errorlevel 1 exit /b errorlevel
msbuild  /p:Configuration=Release MumbleInstall.sln /t:Clean,Build
if errorlevel 1 exit /b errorlevel
perl build_installer.pl
if errorlevel 1 exit /b errorlevel
cd bin\Release
rename Mumble.msi "mumble-%mumblebuildversion%.msi"
if errorlevel 1 exit /b errorlevel
signtool sign /sm /a "mumble-%mumblebuildversion%.msi"
if errorlevel 1 exit /b errorlevel
cd ..\..\..

if "%MUMBLE_SKIP_INTERNAL_SIGNING" == "1" (
	echo Adding build machine's signature to installer
	signtool sign /sm /a "installer/bin/Release/mumble-%mumblebuildversion%.msi"
)

"C:\dev\mumble-releng\tools\collect_symbols.py" collect --version "%mumblebuildversion%" --buildtype "%MUMBLE_BUILD_TYPE%" --product "Mumble" release\ symbols.7z
if errorlevel 1 exit /b errorlevel
