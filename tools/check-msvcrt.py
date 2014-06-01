#!/usr/bin/env python
#
# Copyright (C) 2014 Mikkel Krautz <mikkel@krautz.dk>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# - Neither the name of the Mumble Developers nor the names of its
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# `AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import sys
import subprocess
import platform

def dumpBinDirectives(fn):
	args = ['dumpbin.exe', '/directives', fn]
	p = subprocess.Popen(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	stdout, _ = p.communicate()
	return stdout

def runtimeLibrary(fn):
	directives = dumpBinDirectives(fn)

	defaultLibs = []
	for line in directives.split('\r\n'):
		line = line.strip().lower()
		prefix = '/defaultlib:'
		if line.startswith(prefix):
				defaultLibs.append(line[len(prefix):])

	if 'msvcrt' in defaultLibs:
		return 'MultiThreadedDLL'
	if 'msvcrtd' in defaultLibs:
		return 'MultiThreadedDebugDLL'
	elif 'cmt' in defaultLibs:
		return 'MultiThreaded'
	elif 'cmtd' in defaultLibs:
		return 'MultiThreadedDebug'
	elif 'libc' in defaultLibs:
		return 'SingleThreaded???' # xxx: what does MS use?
	elif 'libcd' in defaultLibs:
		return 'SingleThreadedDebug???' # xxx: what does MS use?

	return None

def main():
	fn = sys.argv[1]
	rtLib = runtimeLibrary(fn)
	if rtLib is None:
		sys.exit(1)
	print rtLib

if __name__ == '__main__':
	main()
