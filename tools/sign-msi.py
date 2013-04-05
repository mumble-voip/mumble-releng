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

# About the tool
# --------------
# sign-msi.py is a tool that takes an unsigned (or optionally, signed)
# Mumble .MSI file and code signs it according to a 'strategy'.
#
# A strategy is a file that lists the files in the .MSI that need
# to be signed to get a 'proper' build. Beside the files listed in
# the strategy, the tool will also sign the .MSI file itself.
#
# Here is a sample strategy file:
#
#     --->8---
#     # Beginning of strategy file. This line is a comment.
#
#     test.exe    # This is the main binary of the program.
#     helper.exe  # this is a helper executable.
#     util.dll    # DLLs are allowed too, of course!
#     --->8----
#
# The mumble-releng repository holds a collection of these files
# in the msi-strategy directory in the root of the repository.
#
# Using the tool
# --------------
# To sign mumble-1.2.4-unsigned.msi according
# to the 1.2.4.strategy file, and output the
# resulting, signed, .MSI to mumble-1.2.4.msi,
# one would do the following:
#
# $ python sign-msi.py \
#      --input=mumble-1.2.4-unsigned.msi \
#      --output=mumble-1.2.4.msi \
#      --strategy=1.2.4.strategy
#
# Signtool parameters
# -------------------
# By default, the tool uses the '/a' parameter to signtool.exe.
#
# Since this is a very personal preference, sign-msi.py can also
# read signtool.exe parameters from the file %USERPROFILE%\.sign-msi.cfg,
# which is the tool's configuration file.
#
# The configuration file uses JSON. For example, to sign using
# a certificate in your personal certificate store and timestamp
# via timestamp.example.com, you could use something like this:
#
#     --->8---
#     {
#         "signtool-args": ["/n", "SubjectName", "/tr", "http://timestamp.example.com"]
#     }
#     --->8---
#
# Note: as mentioned above, if no parameters are specified,
# sign-msi.py will use the "/a" parameter, which asks signtool
# to select the best signing cert automatically.

import os
import sys
import subprocess
import tempfile
import shutil
import json
import distutils.spawn

from optparse import OptionParser

def lookupExe(fn, default):
	'''
	lookupExe tries to look up the executable specified by fn in the
	user's PATH. If that fails, lookupExe returns the value of the
	default parameter.
	'''
	exe = distutils.spawn.find_executable(fn)
	if exe is not None:
		return exe
	else:
		return default

def msidb():
	return lookupExe('msidb.exe', 'C:\\Program Files (x86)\\Windows Kits\\8.0\\bin\\x86\\msidb.exe')

def signtool():
	return lookupExe('signtool.exe', 'C:\\Program Files (x86)\\Windows Kits\\8.0\\bin\\x86\\signtool.exe')

def cmd(args, cwd=None):
	'''
	cmd executes the requested program and throws an exception
	if if the program returns a non-zero return code.
	'''
	ret = subprocess.Popen(args, cwd=cwd).wait()
	if ret != 0:
		raise Exception('command "%s" exited with exit status %i' % (args[0], ret))

def sign(files, cwd=None):
	'''
	sign invokes signtool to sign the given files.
	'''
	cfg = read_cfg()
	signtool_extra_args = ['/a']
	if cfg.has_key('signtool-args'):
		signtool_extra_args = cfg['signtool-args']
	cmd([signtool(), 'sign'] + signtool_extra_args + files, cwd=cwd)

def extractCab(absMsiFn, workDir):
	'''
	extractCab extracts the Mumble.cab file from the MSI file
	given by absMsiFn into workDir.
	'''
	ret = cmd([msidb(), '-d', absMsiFn, '-x', 'Mumble.cab'], cwd=workDir)
	if not os.path.exists(os.path.join(workDir, 'Mumble.cab')):
		raise Exception('no Mumble.cab found in workDir')

def unarchiveCab(workDir):
	'''
	unarchiveCab extracts the content of the Mumble.cab file
	in workDir into a subdirectory of workDir called contents.
	'''
	contentsDir = os.path.join(workDir, 'contents')
	os.mkdir(contentsDir)
	cmd(['expand', os.path.join('..', 'Mumble.cab'), '-F:*', '.'], cwd=contentsDir)

def cabContents(workDir):
	'''
	cabContents returns a directory listing of the
	contents directory.
	'''
	return os.listdir(os.path.join(workDir, 'contents'))

def writeCabDirective(workDir):
	'''
	writeCabDirective writes a Mumble.ddf file to the
	root of workDir.

	This file should can be used as an input to makecab.exe
	to re-create a Mumble.cab.
	'''
	directiveFn = os.path.join(workDir, 'Mumble.ddf')
	allFiles = cabContents(workDir)
	f = open(directiveFn, 'w')
	ddfStr = '''.OPTION EXPLICIT

.Set MaxDiskSize=0
.Set MaxCabinetSize=0
.set DiskDirectoryTemplate=
.Set CabinetNameTemplate=Mumble.cab
.Set Cabinet=on
.Set Compress=on
.Set CompressionType=LZX

'''
	for fn in allFiles:
		ddfStr += fn + '\n'

	f.write(ddfStr)
	f.close()

def signContentFiles(workDir, files):
	'''
	signContentFiles code-signs the files specified
	in the files parameter in the contents directory
	of the workDir.
	'''
	contentsDir = os.path.join(workDir, 'contents')
	sign(files, cwd=contentsDir)

def makeCab(workDir):
	'''
	makeCab creates a new Mumble.cab using the
	files in the contents directory.
	'''
	contentsDir = os.path.join(workDir, 'contents')
	cmd(['makecab.exe', '/f', os.path.join('..', 'Mumble.ddf')], cwd=contentsDir)

def reassembleMsi(absMsiFn, workDir, outFn):
	'''
	reassembleMsi copies the target MSI to the contents
	directory and does the following:

	1. Removes the old Mumble.cab file from it.
	2. Inserts the new Mumble.cab file into it.
	3. Copies the re-assembled MSI to the outFn.
	'''
	contentsDir = os.path.join(workDir, 'contents')
	contentMsi = os.path.join(contentsDir, 'Mumble.msi')
	shutil.copyfile(absMsiFn, contentMsi)

	# Remove old
	cmd([msidb(), '-d', 'Mumble.msi', '-k', 'Mumble.cab'], cwd=contentsDir)
	# Add new
	cmd([msidb(), '-d', 'Mumble.msi', '-a', 'Mumble.cab'], cwd=contentsDir)
	# Copy to outFn
	shutil.copyfile(contentMsi, outFn)

def signMsi(outFn):
	'''
	signMsi code-signs the .MSI file specified
	in outFn.
	'''
	sign([outFn])

def read_cfg():
	'''
	read_cfg returns a dictionary of configuration
	keys for sign-msi.py.
	'''
	fn = os.path.join(os.getenv('USERPROFILE'), '.sign-msi.cfg')
	try:
		with open(fn) as f:
			s = f.read()
			return json.loads(s)
	except (IOError, ValueError):
		pass
	return {}

def read_strategy(fn):
	'''
	read_strategy reads a signing strategy, ignoring all comments.
	It returns all the files from the strategy that need to be code signed.
	'''
	signfiles = []
	for line in open(fn):
		if len(line) == 0:
			continue
		idx = line.find('#')
		if idx != -1:
			line = line[:idx]
		line = line.strip()
		if len(line) == 0:
			continue
		signfiles.append(line)
	return signfiles

def main():
	p = OptionParser(usage='sign-msi.py --input=<in.msi>--output=<out.msi> --strategy=<ver.strategy>')
	p.add_option('', '--input', dest='input', help='Input MSI file')
	p.add_option('', '--output', dest='output', help='Output MSI file')
	p.add_option('', '--strategy', dest='strategy', help='Strategy file describing which files to sign')
	opts, args = p.parse_args()

	if opts.input is None:
		p.error('missing --input')
	if opts.output is None:
		p.error('missing --output')
	if opts.strategy is None:
		p.error('missing --strategy')

	absMsiFn = os.path.abspath(opts.input)
	workDir = tempfile.mkdtemp()
	extractCab(absMsiFn, workDir)
	unarchiveCab(workDir)
	writeCabDirective(workDir)

	contentToSign = read_strategy(opts.strategy)
	signContentFiles(workDir, contentToSign)

	makeCab(workDir)
	reassembleMsi(absMsiFn, workDir, opts.output)
	signMsi(opts.output)

	print ''
	print 'Signed MSI available at %s' % opts.output

if __name__ == '__main__':
	main()