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

# zero-ermine-ld.py zeroes out the 'ermine_ld' section
# of an ELF binary.  For Ermine-packed binaries, this
# section normally contains the LD_LIBRARY_PATH
# environment variable that Ermine must set on startup
# to ensure correct runtime behavior of the packed
# executable.  Our binaries, however, have an RPATH set,
# and does not need any intervention by Ermine to run
# correctly.
#
# Why do we zero it out?  When packing binaries with
# Ermine that depend on libraries which do not live
# in /lib or /usr/lib, Ermine will try to ensure that
# your program has LD_LIBRARY_PATH set up to point
# to all the directories that contain shared libraries
# that the program uses.  We've found that Ermine can
# corrupt the process's initial command line (the memory
# that holds the combined elements of argv, which is
# exposed via /proc/<pid>/cmdline). This resulted in a
# 'corrupted' process name when using 'ps' to list the
# running processes on the system, which lead to user
# confusion.
#
# Since our Ermine-packed binaries do not need an
# LD_LIBRARY_PATH exported, we can avoid this corruption
# by zeroing out the 'ermine_ld' section of the packed
# executable. This ensures we have a proper process
# name in 'ps'.

import os
import sys
import struct
import string
import collections
import tempfile

# struct Elf32_Ehdr
Elf32_Ehdr_Sig = '<16sHHIIIIIHHHHHH'
Elf32_Ehdr_Size = struct.calcsize(Elf32_Ehdr_Sig)
Elf32_Ehdr = collections.namedtuple('Elf32_Ehdr', string.join([
	'e_ident',
	'e_type',
	'e_machine',
	'e_version',
	'e_entry',
	'e_phoff',
	'e_shoff',
	'e_flags',
	'e_ehsize',
	'e_phentsize',
	'e_phnum',
	'e_shentsize',
	'e_shnum',
	'e_shstrndx',
], ' '))

# struct Elf32_Shdr
Elf32_Shdr_Sig = '<IIIIIIIIII'
Elf32_Shdr_Size = struct.calcsize(Elf32_Shdr_Sig)
Elf32_Shdr = collections.namedtuple('Elf32_Shdr', string.join([
	'sh_name',
	'sh_type',
	'sh_flags',
	'sh_addr',
	'sh_offset',
	'sh_size',
	'sh_link',
	'sh_info',
	'sh_addralign',
	'sh_entsize',
], ' '))

def cstr(buf):
	for i in range(0, len(buf)):
		if buf[i] == '\0':
			return buf[0:i]
	raise Exception('not a C str')

def usage():
	print 'zero-ermine-ld.py <fn>'
	sys.exit(1)

def main():
	if len(sys.argv) < 2:
		usage()
	fn = sys.argv[1]
	f = open(fn)
	s = f.read()
	f.close()

	# Extract ELF header and check validity.
	hdr = Elf32_Ehdr._make(struct.unpack(Elf32_Ehdr_Sig, s[:Elf32_Ehdr_Size]))
	if hdr.e_ident[0:4] != '\x7fELF':
		raise Exception('bad ELF')
	
	# Find the shdrs.
	shdrs = []
	for i in range(0, hdr.e_shnum):
		ofs = hdr.e_shoff + i * hdr.e_shentsize
		buf = s[ofs:ofs+Elf32_Shdr_Size]
		shdr = Elf32_Shdr._make(struct.unpack(Elf32_Shdr_Sig, buf))
		shdrs.append(shdr)

	# Index the shdrs by name.
	shdr_map = {}
	shstrtabhdr = shdrs[hdr.e_shstrndx]
	shstroff = shstrtabhdr.sh_offset
	for idx, shdr in enumerate(shdrs):
		if idx == 0: # skip NULL
			continue
		ofs = shstroff + shdr.sh_name
		name = cstr(s[ofs:ofs+4096])
		shdr_map[name] = shdr

	# Write the output ELF, with ermine_ld zeroed out.
	if not shdr_map.has_key('ermine_ld'):
		raise Exception('ELF has no ermine_ld shdr')
	ld = shdr_map['ermine_ld']
	ofs = ld.sh_offset
	sz = ld.sh_size

	f = tempfile.NamedTemporaryFile(delete=False)
	f.write(s[0:ofs])
	f.write('\0'*(sz+1))
	f.write(s[ofs+sz+1:])
	f.flush()
	os.fsync(f.fileno())
	f.close()

	os.rename(f.name, fn)
	os.chmod(fn, 0755)

if __name__ == '__main__':
	main()
