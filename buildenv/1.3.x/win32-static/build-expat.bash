#!/bin/bash -ex

source common.bash
fetch_if_not_exists "http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz"
expect_sha1 "expat-2.1.0.tar.gz" "b08197d146930a5543a7b99e871cba3da614f6f0"

tar -zxf expat-2.1.0.tar.gz
cd expat-2.1.0
cd lib
export CFLAGS="/nologo /DCOMPILED_FROM_DSP /DXML_BUILDING_EXPAT /MD /Zi /Fdlibexpat.pdb /c"
cmd /c cl.exe ${CFLAGS} xmlparse.c xmlrole.c xmltok.c
cmd /c lib.exe xmlparse.obj xmlrole.obj xmltok.obj /out:libexpat.lib
mkdir -p ${MUMBLE_PREFIX}/expat/{lib,include}
cp libexpat.lib ${MUMBLE_PREFIX}/expat/lib/
cp expat*.h ${MUMBLE_PREFIX}/expat/include/