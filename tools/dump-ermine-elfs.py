#!/usr/bin/env python
#
# Copyright (C) 2013 Mikkel Krautz <mikkel@krautz.dk>
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

# dump-ermine-elfs.py is a simple script that dumps all embedded
# ELFs (executables and shared libraries) contained in an Ermine
# packed ELF binary.

import os
import sys

def usage():
	print 'dump-ermine-elfs.py <fn>'
	sys.exit(1)

def main():
	if len(sys.argv) < 2:
		usage()
	fn = sys.argv[1]
	f = open(fn, 'r')
	all = f.read()
	f.close()

	elfMagic = '\x7fELF'
	elfPairs = []
	for i in range(0, len(all)):
		if i == 0: # skip binary itself
			continue
		if all[i:i+len(elfMagic)] == elfMagic:
			elfPairs.append(i)
	elfPairs.append(len(all))

	for i, ofs in enumerate(elfPairs):
		if i == len(elfPairs)-1: # done?
			break
		end = elfPairs[i+1]
		fn = 'dumped-%i.elf' % i
		print 'dumping elf @ 0x%x to %s' % (ofs, fn)
		f = open(fn, 'w')
		f.write(all[ofs:end])
		f.close()

if __name__ == '__main__':
	main()
