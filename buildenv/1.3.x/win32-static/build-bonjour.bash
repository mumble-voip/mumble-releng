#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://www.opensource.apple.com/tarballs/mDNSResponder/mDNSResponder-522.1.11.tar.gz"
expect_sha1 "mDNSResponder-522.1.11.tar.gz" "f73cb3e4c3e9c5d9c029ad95a97893a4fa9d9842"

tar -zxf mDNSResponder-522.1.11.tar.gz
cd mDNSResponder-522.1.11/mDNSWindows

# Fix build with MSVC Express.
printf "#include <windows.h>\r\n" > DLL/afxres.h

# Use the MultiThreadedDLL runtime library.
# We don't use dnssd.vcxproj in our final product, but we're
# modifying it here anyway so we can introduce sanity checking
# scripts that grep the build output for "/MD" vs. "/MT" (etc.)
# in the future.
sed -i -e 's,<RuntimeLibrary>MultiThreaded</RuntimeLibrary>,<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>,g' DLLStub/DLLStub.vcxproj
sed -i -e 's,<RuntimeLibrary>MultiThreaded</RuntimeLibrary>,<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>,g' DLL/dnssd.vcxproj

# Set /ARCH:IA32 for MSVS2012+.
if [ ${VSMAJOR} -gt 10 ]; then
  sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" DLLStub/DLLStub.vcxproj
  sed -i -re "s,<ClCompile>,<ClCompile>\n      <EnableEnhancedInstructionSet>NoExtensions</EnableEnhancedInstructionSet>,g" DLL/dnssd.vcxproj
fi

# Build the DLLStub.
cd DLLStub

cmd /c msbuild DLLStub.vcxproj /p:Configuration=Release /p:PlatformToolset=${MUMBLE_VSTOOLSET}

# Install to a hierarchy that mimics the Bonjour SDK on Windows.
mkdir -p ${MUMBLE_PREFIX}/bonjour/Include
cp ../../mDNSShared/dns_sd.h ${MUMBLE_PREFIX}/bonjour/Include/
mkdir -p ${MUMBLE_PREFIX}/bonjour/Lib/Win32/
cp Win32/Release/dnssdStatic.lib ${MUMBLE_PREFIX}/bonjour/Lib/Win32/dnssd.lib
