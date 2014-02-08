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
# sign-dmg.py is a tool that takes a Mumble .DMG file and
# digitally signs its content (plugins, binaries, codecs, installers).
#
# The .DMG content may already be signed.  In this case, the tool
# will simply replace all the existing signatures.
#
# Using the tool
# --------------
# To sign Mumble-1.2.4-unsigned.dmg, one would do the following:
#
# $ python sign-dmg.py \
#      --input=Mumble-1.2.4-unsigned.dmg \
#      --output=Mumble-1.2.4.dmg
#
# Configuration
# -------------
# The signing behavior of the tool can be configured via a configurtion
# file.  The tool will read its configuration from a $HOME/.sign-dmg.cfg.
#
# The configuration file uses JSON. For example, to sign using a particular
# set of Developer ID certificates in your login keychain, you could use
# something like this:
#
#   --->8---
# 	{
# 		# The keychain needs the .keychain extension explicitly typed out.
# 		"keychain": "login.keychain",
# 		# Your Application certificate.
# 		"developer-id-app": "Developer ID Application: John Appleseed",
# 		# Your Installer certificate.
# 		"developer-id-installer": "Developer ID Installer: John Appleseed"
# 	}
#   --->8---

import os
import sys
import subprocess
import tempfile
import shutil
import json
import plistlib
import StringIO
import string
import platform
import distutils.spawn

from optparse import OptionParser

# requirements specifies a set of codesign
# requirements for Mumble executables.
#
# We require an Apple CA and a Developer ID
# leaf certificate (the one we're signing with).
# The 'designated' line is specifically tuned to
# work on older versions of Mac OS X that aren't
# Developer ID-aware without breakage.
#
# We also explicitly require all shard libraries
# to be codesigned by Apple. (We can reasonably do
# that because Mumble is statically built on
# Mac OS X.)
requirements = '''designated => anchor apple generic and identifier "${identifier}" and (certificate leaf[field.1.2.840.113635.100.6.1.9] /* exists */ or certificate 1[field.1.2.840.113635.100.6.2.6] /* exists */ and certificate leaf[field.1.2.840.113635.100.6.1.13] /* exists */ and certificate leaf[subject.OU] = "${subject_OU}")
library => anchor apple'''

def homedir():
	'''
	homedir returns the user's home directory.
	'''
	return os.getenv('HOME')

def cmd(args, cwd=None):
	'''
	cmd executes the requested program and throws an exception
	if if the program returns a non-zero return code.
	'''
	print args
	ret = subprocess.Popen(args, cwd=cwd).wait()
	if ret != 0:
		raise Exception('command "%s" exited with exit status %i' % (args[0], ret))

def read_cfg():
	'''
	read_cfg returns a dictionary of configuration
	keys for sign-dmg.py.
	'''
	fn = os.path.join(homedir(), '.sign-dmg.cfg')
	try:
		with open(fn) as f:
			s = f.read()
			return json.loads(s)
	except (IOError, ValueError):
		pass
	return {}

def certificateSubjectOU():
	'''
	certificateSubjectOU extracts the subject OU from the Application
	DeveloperID certificate that is specified in the script's configuration.
	'''
	cfg = read_cfg()
	findCert = subprocess.Popen(('/usr/bin/security', 'find-certificate', '-c', cfg['developer-id-app'], '-p', cfg['keychain']), stdout=subprocess.PIPE)
	pem, _ = findCert.communicate()

	openssl = subprocess.Popen(('/usr/bin/openssl', 'x509', '-subject', '-noout'), stdout=subprocess.PIPE, stdin=subprocess.PIPE)
	subject, _ = openssl.communicate(pem)

	attr = '/OU='
	begin = subject.index(attr) + len(attr)
	tmp = subject[begin:]
	end = tmp.index('/')

	return tmp[:end]

def lookupFileIdentifier(path):
	'''
	lookupFileIdentifier looks up a bundle identifier suitable for use when signing
	the app bundle or binary at path.
	'''
	try:
		d = plistlib.readPlist(os.path.join(path, 'Contents', 'Info.plist'))
		return d['CFBundleIdentifier']
	except:
		return os.path.basename(path)

def codesign(path):
	'''
	codesign call the codesign executable on the signable object(s) given by path.
	'''
	cfg = read_cfg()
	OU = certificateSubjectOU()
	if hasattr(path, 'isalpha'):
		path = (path,)
	for prog in path:
		identifier = lookupFileIdentifier(prog)
		reqs = string.Template(requirements).substitute({
			'identifier': identifier,
			'subject_OU': OU,
		})
		cmd(['codesign', '--force', '--keychain', cfg['keychain'], '-vvvv', '-i', identifier, '-r='+reqs, '-s', cfg['developer-id-app'], prog])
	return 0

def prodsign(inf, outf):
	'''
	prodsign calls the prodsign executable to sign the product at inf, outputting a signed blob to outf.
	'''
	cfg = read_cfg()
	cmd(['productsign', '--keychain', cfg['keychain'], '--sign', cfg['developer-id-installer'], inf, outf])

def volNameForMountedDMG(mountPoint):
	diskutil = subprocess.Popen(['diskutil', 'info', '-plist', mountPoint], stdout=subprocess.PIPE)
	plist, _ = diskutil.communicate()
	fileLikePlist = StringIO.StringIO(plist)
	diskInfo = plistlib.readPlist(fileLikePlist)
	return diskInfo['VolumeName']

def extractDMG(absFn, workDir):
	'''
	extractDMG extracts the DMG at absFn into the content subdirectory
	of workDir.

	It returns the volume name of the extracted DMG.
	'''
	mountDir = os.path.join(workDir, 'mount')
	os.mkdir(mountDir)
	cmd(['hdiutil', 'mount', '-readonly', '-mountpoint', mountDir, absFn])
	volName = volNameForMountedDMG(mountDir)
	contentDir = os.path.join(workDir, 'content')
	os.mkdir(contentDir)
	for fn in os.listdir(mountDir):
		if fn == '.Trashes':
			continue
		src = os.path.join(mountDir, fn)
		dst = os.path.join(contentDir, fn)
		if os.path.islink(src):
			target = os.readlink(src)
			os.symlink(target, dst)
		elif os.path.isdir(src):
			shutil.copytree(src, dst, True)
		else:
			shutil.copy(src, dst)
	cmd(['umount', mountDir])
	return volName

def signApp(workDir):
	'''
	signApp signs the Mumble app bundle in the content subdirectory of workDir.
	'''

	app = os.path.join(workDir, 'content', 'Mumble.app')

	plugins = []
	pluginsBase = os.path.join(app, 'Contents', 'Plugins')
	for plugin in os.listdir(pluginsBase):
		plugins.append(os.path.join(pluginsBase, plugin))

	codecs = []
	codecsBase = os.path.join(app, 'Contents', 'Codecs')
	for codec in os.listdir(codecsBase):
		codecs.append(os.path.join(codecsBase, codec))

	binaries = []
	binariesBase = os.path.join(app, 'Contents', 'MacOS')
	for binary in os.listdir(binariesBase):
		if binary == 'Mumble':
			continue
		binaries.append(os.path.join(binariesBase, binary))

	signProducts = plugins + codecs + binaries
	codesign(signProducts)

	overlayInst = os.path.join(app, 'Contents', 'Resources', 'MumbleOverlay.pkg')
	os.rename(overlayInst, overlayInst+'.intermediate')
	prodsign(overlayInst+'.intermediate', overlayInst)
	os.remove(overlayInst+'.intermediate')

	codesign(app)

def makeDMG(workDir, volName, absInFn, absOutFn):
	'''
	makeDMG makes a new DMG for the Mumble app that resides in the workDir's
	content subdirectory.
	'''
	cmd(['hdiutil', 'create', '-srcfolder', os.path.join(workDir, 'content'),
		 '-format', 'UDBZ', '-volname', volName, absOutFn])

def main():
	p = OptionParser(usage='sign-dmg.py --input=<in.dmg> --output=<out.dmg> [--keep-tree]')
	p.add_option('', '--input', dest='input', help='Input DMG file')
	p.add_option('', '--output', dest='output', help='Output DMG file')
	p.add_option('', '--keep-tree', action='store_true', dest='keep_tree', help='Keep the working tree after signing')
	opts, args = p.parse_args()

	if opts.input is None:
		print 'No --input parameter specified'
		sys.exit(1)
	if opts.output is None:
		print 'No --output parameter specified'
		sys.exit(1)

	absDMGFn = os.path.abspath(opts.input)
	absDMGOutFn = os.path.abspath(opts.output)
	workDir = tempfile.mkdtemp()

	volName = extractDMG(absDMGFn, workDir)
	signApp(workDir)
	makeDMG(workDir, volName, absDMGFn, absDMGOutFn)

	if opts.keep_tree:
		print ''
		print 'Working tree: %s' % workDir
	else:
		shutil.rmtree(workDir, ignore_errors=True)

	print ''
	print 'Signed DMG available at %s' % opts.output

if __name__ == '__main__':
	main()