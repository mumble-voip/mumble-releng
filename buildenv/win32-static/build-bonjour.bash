#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.opensource.apple.com/tarballs/mDNSResponder/mDNSResponder-333.10.tar.gz"
expect_sha1 "mDNSResponder-333.10.tar.gz" "63ed2021dce028b8460cc78c137e1903ccd5288a"

tar -zxf mDNSResponder-333.10.tar.gz
cd mDNSResponder-333.10/mDNSWindows

# Fix build with MSVC Express.
printf "#include <windows.h>\r\n" > DLL/afxres.h

# Build the DLLStub.
cd DLLStub
cmd /c msbuild DLLStub.vcxproj /p:Configuration=Release

# Install to a hierarchy that mimics the Bonjour SDK on Windows.
mkdir -p ${MUMBLE_PREFIX}/bonjour/Include
cp ../../mDNSShared/dns_sd.h ${MUMBLE_PREFIX}/bonjour/Include/
mkdir -p ${MUMBLE_PREFIX}/bonjour/Lib/Win32/
cp Win32/Release/dnssdStatic.lib ${MUMBLE_PREFIX}/bonjour/Lib/Win32/dnssd.lib
