#!/usr/bin/env python
#
# Copyright 2017 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# A simple script that uses the code signing facilities of sign-msi.py
# to sign a single PE binary (.exe or .dll).

from __future__ import (unicode_literals, print_function, division)

import os
import sys
import shutil
from optparse import OptionParser

# Use utilities from sign-msi.py
sys.path.insert(0, os.path.dirname(__file__))
msi = __import__("sign-msi")

if __name__ == '__main__':
	p = OptionParser(usage='sign-pe.py --input=<in> --output=<out>')
	p.add_option('', '--input', dest='input', help='Input PE file')
	p.add_option('', '--output', dest='output', help='Output PE file')
	opts, args = p.parse_args()

	if opts.input is None:
		print('No --input parameter specified')
		sys.exit(1)
	if opts.output is None:
		print('No --output parameter specified')
		sys.exit(1)

	absIn = os.path.abspath(opts.input)
	absOut = os.path.abspath(opts.output)
	shutil.copy(absIn, absOut)
	msi.sign([absOut])
