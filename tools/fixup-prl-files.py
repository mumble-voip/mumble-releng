#!/usr/bin/env python
# -*- coding: utf-8
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# fixup-prl-files.py walks through all of the .prl
# files in an installed Qt prefix and fixes the
# QMAKE_PRL_LIBS line to correctly point to the
# install prefix instead of the build directory.

from __future__ import (unicode_literals, print_function, division)

import collections
import os
import sys
import shutil

PathVariant = collections.namedtuple('PathVariant', ['pathSeparator', 'buildDir', 'installDir'])

def prlWindowsPath(path):
	# Qt's .prl files use double backslashes
	if path.find('\\\\') == -1:
		path = path.replace('\\', '\\\\')
	return path

def rewritePrl(fn, buildDir, installDir):
	buf = None
	with open(fn, 'r') as f:
		buf = f.read()

	lines = [line for line in buf.split('\n')]

	# Make a backup of the original '.prl'-file.
	shutil.copyfile(fn, fn+'.orig')

	pathVariants = (
		PathVariant(
			pathSeparator='\\\\',
			buildDir=prlWindowsPath(buildDir),
			installDir=prlWindowsPath(installDir)
		),
		PathVariant(
			pathSeparator='/',
			buildDir=buildDir.replace('\\', '/'),
			installDir=installDir.replace('\\', '/')
		),
	)

	for pathVariant in pathVariants:
		pathSeparator = pathVariant.pathSeparator
		buildDir = pathVariant.buildDir
		installDir = pathVariant.installDir
		for idx, line in enumerate(lines):
			if line.startswith('QMAKE_PRL_LIBS'):
				# Fix the QMAKE_PRL_LIBS line.
				#
				# Qt is known to 'sanitize' the drive letter
				# of our build directory, so attempt to perform
				# the replacement with both a 'C:\' (uppercase)
				# and a 'c:\' (suffix). (Note: the driver letter
				# can be anything, not just C:!)
				#
				# Both buildDir and installDir are guaranteed to have
				# a drive-letter prefix at this point in the program's
				# execution.
				buildDir = buildDir[0].upper() + buildDir[1:]
				line = line.replace(buildDir, installDir)

				buildDir = buildDir[0].lower() + buildDir[1:]
				line = line.replace(buildDir, installDir)

				# Qt 5 will sometimes point certain libs to <build_dir>/qtbase/lib/,
				# but these libs live in <install_dir>/lib.
				line = line.replace('qtbase{0}'.format(pathSeparator), '')

				lines[idx] = line

	# Sanity check the output before writing it.
	for pathVariant in pathVariants:
		pathSeparator = pathVariant.pathSeparator
		buildDir = pathVariant.buildDir
		installDir = pathVariant.installDir
		for line in lines:
			if line.startswith('QMAKE_PRL_LIBS'):
				# Check that there are no 'qtbase' references left in QMAKE_PRL_LIBS.
				if 'qtbase' in line.lower():
					raise Exception('unexpected reference to \'qtbase\' found in the QMAKE_PRL_LIBS')

				# Perform a sanity check. The 'simple' string replace of the buildDir
				# above can fail because of a subtle difference between the build-dir
				# path found in the '.prl'-file, and the build-dir passed to this tool.
				#
				# An example of this is the case handled above: if the build dir in the
				# '.prl'-file uses a lower case 'C:\'-prefix, and this tool is passed the
				# lower-case variant: 'c:\'.
				#
				# Now, that case is already handled above -- but perhaps other subtle path-
				# related things can still happen, such as paths being written to the
				# '.prl'-file as lower case.
				#
				# To detect these kinds of issues, we perform a simple sanity check:
				#  1. Convert the QMAKE_PRL_LIBS line to lowercase
				#  2. Convert the buildDir and installDir to lowercase
				#  3. Check if there are still any references to the buildDir in the
				#     converted string from step 1.
				if buildDir.lower() in line.lower():
					raise Exception('unexpectedly found reference to the build directory ({0}) in the semi-processed QMAKE_PRL_LIBS line: {1}'.format(buildDir, line))

	with open(fn, 'w') as f:
		f.write('\n'.join(lines))

def isAbsPath(fn):
	if not os.path.abspath(fn):
		return False
	if not fn[0].isalpha() and fn[1] != ':':
		return False
	return True

def main():
	if len(sys.argv) < 3:
		print('Usage: python fixup-prl-files.py <abs-build-dir> <abs-install-dir>')
		print('')
		print(' For example:')
		print('   python cleanup-buildenv-build-dir.py "c:\\MumbleBuild\\win32-static-1.3.x-2014-06-01-cf59267.build\\mumble-developers-qt" "c:\\MumbleBuild\\win32-static-1.3.x-2014-06-01-cf59267\\Qt4.8"')
		sys.exit(1)

	buildDir = sys.argv[1]
	installDir = sys.argv[2]

	if not isAbsPath(buildDir):
		raise Exception('The specified abs-build-dir "{0}" is not an absolute path'.format(buildDir))
	if not isAbsPath(installDir):
		raise Exception('The specified abs-install-dir "{0}" is not an absolute path'.format(installDir))

	for dirpath, dirnames, filenames in os.walk(installDir):
		for fn in filenames:
			_, ext = os.path.splitext(fn)
			if ext.lower() == '.prl':
				absFn = os.path.join(dirpath, fn)
				rewritePrl(absFn, buildDir, installDir)

if __name__ == '__main__':
	main()
