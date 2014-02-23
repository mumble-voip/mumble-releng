#!/usr/bin/env python
#
# Copyright (C) 2013-2014 Mikkel Krautz <mikkel@krautz.dk>
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
import platform
import distutils.spawn

from optparse import OptionParser

altconfig = None

def homedir():
	'''
	homedir returns the user's home directory.
	'''
	return os.getenv('USERPROFILE', os.getenv('HOME'))

class winpath(str):
	'''
	winpath is a str subclass that the cmd() function uses
	to translate Unix-style paths to Windows-style paths when
	invoking Windows binaries through Wine.	
	'''
	def to_windows(self, cwd=None):
		if cwd is None:
			cwd = os.getcwd()
		path = str(self)
		if not os.path.isabs(path):
			path = os.path.normpath(os.path.join(cwd, path))
		return 'z:' + path.replace('/', '\\')

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

def osslsigncode():
	return lookupExe('osslsigncode', '/usr/local/osslsigncode')

def cmd(args, cwd=None):
	'''
	cmd executes the requested program and throws an exception
	if if the program returns a non-zero return code.
	'''
	# Translate from Unix-style to Windows-style paths if needed.
	if platform.system() != "Windows":
		for i, arg in enumerate(args):
			if isinstance(arg, winpath):
				args[i] = arg.to_windows(cwd)
	ret = subprocess.Popen(args, cwd=cwd).wait()
	if ret != 0:
		raise Exception('command "%s" exited with exit status %i' % (args[0], ret))

def hasSignature(absFn):
	'''
	hasSignature returns true if absFn has a digital signature.
	'''
	if platform.system() == 'Windows':
		raise Exception('not supported on Windows')
	ret = subprocess.Popen([osslsigncode(), 'extract-signature', '-in', absFn, '-out', '/dev/null']).wait()
	if ret == 0:
		return True
	elif ret == 255:
		return False
	else:
		raise Exception('unexpected osslsigncode return code: %i' % ret)

def signatureLeafHashMatches(absFn, sha512):
	'''
	signatureLeafHashMatches performs a signature check on absFn.

	The signature check determines whether the sha512 digest of
 	the leaf certificate of the signature's certificate chain
	matches the passed-in sha512 digest.
	'''
	if platform.system() == 'Windows':
		raise Exception('not supported on Windows')
	args = ['osslsigncode', 'verify', '-require-leaf-hash', 'sha512:'+sha512, '-in', absFn]
	return subprocess.Popen(args).wait() == 0

def hasTrustedSignature(absFn):
	'''
	hasTrustedSignature checks whether absFn has a leaf hash
	that matches one of the trusted leaf hashes as found in
	the sign-msi.py configuration file.
	'''
	if platform.system() == "Windows":
		raise Exception('not supported on Windows')
	cfg = read_cfg()
	trustedSignatures = cfg.get('trusted-leaf-sha512s', [])
	for trusted in trustedSignatures:
		if signatureLeafHashMatches(absFn, trusted):
			return True
	return False

def sign(files, cwd=None, force=False, productDescription=None, productURL=None):
	'''
	sign invokes signtool (on Windows) or osslsigncode (on everything else)
	to sign the given files.
	
	Passing in force=True will always replace the signature
	of the files to be signed, without respecting the
	allow-already-signed configuration flag. (Which also means
	that objects signed with force=True aren't checked against
	the trusted-leaf-sha512s of the configuration file, either.)
	'''
	if cwd is None:
		cwd = os.getcwd()
	cfg = read_cfg()
	if platform.system() == "Windows":
		signtool_product_args = []
		if productDescription:
			signtool_product_args.extend(['/d', productDescription])
		if productURL:
			signtool_product_args.extend(['/du', productURL])
		signtool_extra_args = ['/a']
		if cfg.has_key('signtool-args'):
			signtool_extra_args = cfg['signtool-args']
		cmd([signtool(), 'sign'] + signtool_product_args + signtool_extra_args + files, cwd=cwd)
	else:
		osslsigncode_product_args = []
		if productDescription:
			osslsigncode_product_args.extend(['-n', productDescription])
		if productURL:
			osslsigncode_product_args.extend(['-i', productURL])
		osslsigncode_args = cfg.get('osslsigncode-args', [])

		allowAlreadySignedContent = cfg.get('allow-already-signed-content', False)
		reSignAlreadySignedContent = cfg.get('re-sign-already-signed-content', False)
		if reSignAlreadySignedContent == True and allowAlreadySignedContent == False:
			raise Excpetion('cannot have re-sign-already-signed-contnet == true when allow-already-signed-content == false')

		for fn in files:
			absFn = os.path.join(cwd, fn)
			if force is False and hasSignature(absFn):
				if not allowAlreadySignedContent:
					raise Exception('object "%s" is already signed; cfg disallows that.' % fn)
				if not hasTrustedSignature(absFn):
					raise Exception('object "%s" has a bad signature.' % fn)
				if not reSignAlreadySignedContent:
					print 'Skipping %s - signed by a trusted leaf.' % fn
					continue
			print 'Signing %s' % fn
			os.rename(absFn, absFn+'.orig')
			cmd([osslsigncode(), 'sign'] + osslsigncode_product_args + osslsigncode_args + [absFn+'.orig', absFn])

def extractCab(absMsiFn, workDir):
	'''
	extractCab extracts the Mumble.cab file from the MSI file
	given by absMsiFn into workDir.
	'''
	ret = cmd([msidb(), '-d', winpath(absMsiFn), '-x', 'Mumble.cab'], cwd=workDir)
	if not os.path.exists(os.path.join(workDir, 'Mumble.cab')):
		raise Exception('no Mumble.cab found in workDir')

def unarchiveCab(workDir):
	'''
	unarchiveCab extracts the content of the Mumble.cab file
	in workDir into a subdirectory of workDir called contents.
	'''
	contentsDir = os.path.join(workDir, 'contents')
	os.mkdir(contentsDir)
	cmd(['expand.exe', winpath(os.path.join('..', 'Mumble.cab')), '-F:*', '.'], cwd=contentsDir)

def cabContents(workDir):
	'''
	cabContents returns a directory listing of the
	contents directory, sorted in a 'CAB correct' manner.
	'''
	return sorted(os.listdir(os.path.join(workDir, 'contents')), key=str.lower)

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

def signContentFiles(workDir, files=None):
	'''
	signContentFiles code-signs the files specified
	in the files parameter in the contents directory
	of the workDir.

	If files is None, signContentFiles will sign all
	.EXE and .DLL files in the 'contents' subdirectory
	of the workDir.
	'''
	contentsDir = os.path.join(workDir, 'contents')
	if files is None:
		def isSignable(fn):
			fn = fn.lower()
			return fn.endswith('.exe') or fn.endswith('.dll')
		files = [fn for fn in os.listdir(contentsDir) if isSignable(fn)]
	sign(files, cwd=contentsDir)

def makeCab(workDir):
	'''
	makeCab creates a new Mumble.cab using the
	files in the contents directory.
	'''
	contentsDir = os.path.join(workDir, 'contents')
	cmd(['makecab.exe', '/f', winpath(os.path.join('..', 'Mumble.ddf'))], cwd=contentsDir)

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

def signMsi(outFn, productDescription=None, productURL=None):
	'''
	signMsi code-signs the .MSI file specified
	in outFn.
	'''
	sign([outFn], force=True, productDescription=productDescription, productURL=productURL)

def read_cfg():
	'''
	read_cfg returns a dictionary of configuration
	keys for sign-msi.py.
	'''
	global altconfig
	fn = os.path.join(homedir(), '.sign-msi.cfg')
	if altconfig is not None:
		fn = altconfig
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
	p = OptionParser(usage='sign-msi.py --input=<in.msi> --output=<out.msi> [--strategy=<ver.strategy>]')
	p.add_option('', '--input', dest='input', help='Input MSI file')
	p.add_option('', '--output', dest='output', help='Output MSI file')
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

	absMsiFn = os.path.abspath(opts.input)
	workDir = tempfile.mkdtemp()
	extractCab(absMsiFn, workDir)
	unarchiveCab(workDir)
	writeCabDirective(workDir)

	contentToSign = None
	if opts.strategy is not None:
		contentToSign = read_strategy(opts.strategy)
	signContentFiles(workDir, contentToSign)

	makeCab(workDir)
	reassembleMsi(absMsiFn, workDir, opts.output)

	productName = os.path.basename(opts.output)
	signMsi(opts.output, productDescription=productName)

	if opts.keep_tree:
		print ''
		print 'Working tree: %s' % workDir
	else:
		shutil.rmtree(workDir, ignore_errors=True)

	print ''
	print 'Signed MSI available at %s' % opts.output

if __name__ == '__main__':
	main()
