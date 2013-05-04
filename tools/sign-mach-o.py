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

# A simple script that uses the code signing facilities of sign-dmg.py
# to sign a single Mach-O binary.

import os
import sys
import shutil
from optparse import OptionParser

# Use utilities from sign-dmg.py
sys.path.insert(0, os.path.dirname(__file__))
dmg = __import__("sign-dmg")

if __name__ == '__main__':
	p = OptionParser(usage='sign-mach-o.py --input=<in> --output=<out>')
	p.add_option('', '--input', dest='input', help='Input Mach-O file')
	p.add_option('', '--output', dest='output', help='Output Mach-O file')
	opts, args = p.parse_args()

	if opts.input is None:
		print 'No --input parameter specified'
		sys.exit(1)
	if opts.output is None:
		print 'No --output parameter specified'
		sys.exit(1)

	absIn = os.path.abspath(opts.input)
	absOut = os.path.abspath(opts.output)
	shutil.copy(absIn, absOut)
	dmg.codesign(absOut)