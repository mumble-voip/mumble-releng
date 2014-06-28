#!/bin/bash -ex
# Copyright 2013-2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

source common.bash
fetch_if_not_exists "http://downloads.sourceforge.net/project/expat/expat/2.1.0/expat-2.1.0.tar.gz"
expect_sha1 "expat-2.1.0.tar.gz" "b08197d146930a5543a7b99e871cba3da614f6f0"

tar -zxf expat-2.1.0.tar.gz
cd expat-2.1.0
cd lib
export CFLAGS="/nologo /DCOMPILED_FROM_DSP /DXML_BUILDING_EXPAT /D_USRDLL /MD /Zi /Fd /c"
cmd /c cl.exe ${CFLAGS} xmlparse.c xmlrole.c xmltok.c
cmd /c link.exe /dll /def:libexpat.def /implib:libexpat.lib /out:libexpat.dll /debug /pdb:libexpat.pdb xmlparse.obj xmlrole.obj xmltok.obj
mkdir -p ${MUMBLE_PREFIX}/expat/{lib,include}
cp libexpat.{lib,dll,pdb} ${MUMBLE_PREFIX}/expat/lib/
cp expat*.h ${MUMBLE_PREFIX}/expat/include/