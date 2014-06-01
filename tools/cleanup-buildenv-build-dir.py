#!/usr/bin/env python
# -*- coding: utf-8
# Copyright 2014 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# cleanup-buildenv-build-dir.py cleans up the
# '<buildenv-name>.build' directories that are
# used for storing source zips, tarballs and source
# trees when a build env is being built.
#
# This script can be used to trim such a directory
# after the build environment has finished building.
# We can't just remove the whole directory in all cases.
# Often times, the '.build' directory will include
# debugging symbols and other things we want to keep
# around. This script takes care not to delete the
# things we want to keep.

from __future__ import (unicode_literals, print_function, division)

import os
import sys
import platform
import ctypes

# The file extensions of files to keep around.
KEEP_EXT = (
	# We need to keep '.pdb' files around in the
	# buildenv's .build directory, at least for
	# the win32-static build environment. This
	# is because the static libraries in that
	# environment make use of "object file PDBs",
	# which are files named "vc120.pdb" (for
	# MSVS2013). The paths of these files are
	# hard-coded in the object files of the
	# static libraries, and need to be kept
	# around in order to be able to generate
	# "proper" PDB files (linker PDBs) during
	# linking of DLLs and EXEs.
	'pdb',

	# Files with the '.dbg' extension are typically
	# files that we extract ourselves using tools
	# like 'objdump'. This is to avoid shipping
	# unnecessary debug symbols with all Mumble
	# build products.
	'dbg'
)

def makeAbs(path, unc=True):
	'''
	Converts the specified path to an absolute path.

	On Windows, if unc is True, the function will convert the
	path to a UNC-style path, allowing some APIs to escape the 255 character
	limit of Win32 paths.
	'''
	if platform.system() == 'Windows':
		uncpart = ''
		if unc:
			uncpart = '\\\\?\\'
		alpha = list(range(ord('a'), ord('z'))) + list(range(ord('A'), ord('Z')))
		drive = None
		sep = None
		absolute = True

		if len(path) > 2 and path[0] in alpha and path[1] == ':':
			drive = path[0]
			sep = path[2]

		if len(path) > 0 and path[0] == '/' or path[0] == '\\':
			sep = path[0]

		if sep is None:
			absolute = False

		if not absolute:
			return uncpart + os.path.join(os.getcwd(), path)
		else:
			if sep == '/':
				path = path.replace(sep, '\\')
			if not drive:
				drive = os.getcwd()[0]
				path = drive + ':' + path
			return uncpart + path
	else:
		if os.path.isabs(path):
			return path
		return os.path.join(os.getcwd(), path)

def rm(fn):
	'''
	Removes the file at fn.

	On Windows systems, this function has special
	cases that allow some otherwise hard-to-delete
	files to be deleted anyway.

	On all other systems, calling this function
	is equivalent to calling os.remove().
	'''
	if platform.system() == 'Windows':
		try:
			os.remove(fn)
		except WindowsError, e:
			# Some of our files can be set to read only,
			# or have other arcane permissions and flags
			# set. In many of these cases, Python's
			# os.remove() will fail with a Win32 'access
			# denied' error (0x5).
			#
			# The 'fix' is to change the file's attributes
			# to FILE_ATTRIBUTE_NORMAL and then to retry
			# deleting the file.
			ERROR_ACCESS_DENIED   = 0x05
			FILE_ATTRIBUTE_NORMAL = 0x80
			if e.winerror == ERROR_ACCESS_DENIED:
				if ctypes.windll.kernel32.SetFileAttributesW(unicode(fn), FILE_ATTRIBUTE_NORMAL) == 0:
					errno = ctypes.windll.kernel32.GetLastError()
					raise Exception('SetFileAttributesW failed with error code {0}'.format(errno))
				os.remove(fn)
			else:
				raise
	else:
		os.remove(fn)

def main():
	if len(sys.argv) < 2:
		print('Usage: python cleanup-buildenv-build-dir.py <build-dir>')
		print('')
		print(' For example:')
		print('   python cleanup-buildenv-build-dir.py /MumbleBuild/centos-ermine-1.2.x-2014-06-01-cf59267.build')
		sys.exit(1)

	build_dir = sys.argv[1]

	for dirpath, dirnames, filenames in os.walk(build_dir):
		for fn in filenames:
			absFn = makeAbs(os.path.join(dirpath, fn))
			ext, _ = os.path.splitext(fn.lower())
			if not ext in KEEP_EXT:
				rm(absFn)

if __name__ == '__main__':
	main()
