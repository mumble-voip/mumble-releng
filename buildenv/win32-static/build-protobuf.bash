#!/bin/bash -ex

source common.bash
fetch_if_not_exists "https://protobuf.googlecode.com/files/protobuf-2.5.0.zip"
expect_sha1 "protobuf-2.5.0.zip" "e6e769b37eb0f8a9507b4525615bb3d798cd5750"

unzip -o protobuf-2.5.0.zip
cd protobuf-2.5.0/vsprojects

cmd /c extract_includes.bat

sed -i -re 's/Format Version 9.00/Format Version 11.00/g;
            s/Visual Studio 2005/Visual Studio 2010/g;
            s/\.vcproj/\.vcxproj/g;' protobuf.sln

for fn in `ls *.vcproj`; do
	cmd /c vcupgrade.exe -overwrite ${fn}
done

sed -i -re 's/Name="gtest"/Name="gtest" RelativePathToProject="gtest.vcproj"/g;' ../gtest/msvc/gtest_main.vcproj
cmd /c vcupgrade.exe -overwrite ..\\gtest\\msvc\\gtest.vcproj
cmd /c vcupgrade.exe -overwrite ..\\gtest\\msvc\\gtest_main.vcproj

cmd /c python.exe $(cygpath -w ${MUMBLE_BUILDENV_ROOT}/../../tools/vs-sln-convert-to-per-project-deps.py) protobuf.sln

cmd /c msbuild.exe protobuf.sln /p:Configuration=Release

cd Release
cmd /c lite-test.exe
cmd /c tests.exe
cd ..

mkdir -p ${MUMBLE_PREFIX}/protobuf/vsprojects/Release/
cp -R include ${MUMBLE_PREFIX}/protobuf/vsprojects/include
cp -R Release/*.{exe,pdb,lib} ${MUMBLE_PREFIX}/protobuf/vsprojects/Release/
