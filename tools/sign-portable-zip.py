#!/usr/bin/env python
#
# Copyright (C) 2013-2015 Mikkel Krautz <mikkel@krautz.dk>
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

# A tool to sign a "Portable ZIP" file. Uses the same args
# and configuration as sign-msi.py.

import os
import sys
import subprocess
import tempfile
import shutil
import json
import platform
import distutils.spawn

from optparse import OptionParser

# Use utilities from sign-msi.py
sys.path.insert(0, os.path.dirname(__file__))
msi = __import__("sign-msi")

altconfig = None

def extractZip(absZipFn, workDir):
	msi.cmd(["unzip", absZipFn], cwd=workDir)

	# After extracting the ZIP file, we expect the
	# workDir to only contain single directory
	# with the contents of the ZIP file.
	# Rename it to "contents" to make sign-msi.py's
	# signContentFiles happy.
	dirs = os.listdir(workDir)
	if len(dirs) > 1:
		raise Exception('workDir contains more than one item')

	zipDir = dirs[0]
	os.rename(os.path.join(workDir, zipDir), os.path.join(workDir, 'contents'))

def makeZip(workDir, outputAbsZipFn):
	# Rename content dir to the basename (with the extension stripped).
	if outputAbsZipFn.lower()[-4:] != '.zip':
		raise Exception('output name does not end in .zip. can not figure out dir name')
	zipDir = os.path.basename(outputAbsZipFn)[:-4]
	os.rename(os.path.join(workDir, 'contents'), os.path.join(workDir, zipDir))

	# Make the zip
	msi.cmd(["zip", "-r", outputAbsZipFn, zipDir], cwd=workDir)

def main():
	p = OptionParser(usage='sign-portable-zip.py --input=<in.zip> --output=<out.zip> [--strategy=<ver.strategy>]')
	p.add_option('', '--input', dest='input', help='Input ZIP file')
	p.add_option('', '--output', dest='output', help='Output ZIP file')
	p.add_option('', '--strategy', dest='strategy', help='Strategy file describing which files to sign (optional; if not present, all files will be signed)')
	p.add_option('', '--keep-tree', action='store_true', dest='keep_tree', help='Keep the working tree after signing')
	p.add_option('', '--config', dest='config', help='Load the specified config file instead of $HOME/.sign-msi.cfg')
	opts, args = p.parse_args()

	if opts.input is None:
		p.error('missing --input')
	if opts.output is None:
		p.error('missing --output')

	if opts.config is not None:
		global altconfig
		altconfig = opts.config

	absZipFn = os.path.abspath(opts.input)
	workDir = tempfile.mkdtemp()
	extractZip(absZipFn, workDir)

	contentToSign = None
	if opts.strategy is not None:
		contentToSign = msi.read_strategy(opts.strategy)
	msi.signContentFiles(workDir, contentToSign)

	makeZip(workDir, opts.output)

	if opts.keep_tree:
		print ''
		print 'Working tree: %s' % workDir
	else:
		shutil.rmtree(workDir, ignore_errors=True)

	print ''
	print 'Signed ZIP available at %s' % opts.output

if __name__ == '__main__':
	main()

