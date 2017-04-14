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
import glob
import argparse
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

# Globs for paths that should be cleaned regardless of
# extension. Can point to single files.
ADDITIONAL_CLEANUP = [
	# The vast majority of the PDBs are for test binaries
	# our dependent builds produce. We do not need those
	# after we ran the tests and have no need to distribute
	# them. The list below tries to be somewhat dependency
	# version independent but will require manual attention
	# from time to time. Windirstat can be a great help to
	# see if something big slipped through the cleanup.
	"ice-*/cpp/test/*",
	"ice-*/cpp/bin/*",
	"ice-*/cpp/src/*Grid*/",
	"ice-*/cpp/src/*Glacier*/",
	"ice-*/cpp/src/*Freeze*/",
	"qt-everywhere-opensource-src-*/qttools/*",
	"qt-everywhere-opensource-src-*/qtdeclarative/*",
	"qt-everywhere-opensource-src-*/qtbase/bin/*", # uic.pdb, rcc.pdb, ...
	"openssl-*/out32/*test.pdb",
	"protobuf-*/vsprojects/Release/*test*.pdb"
]

verbose = False
dryrun = False

def makeAbs(path, unc=True):
	'''
	Converts the specified path to an absolute path.

	On Windows, if unc is True, the function will convert the
	path to a UNC-style path, allowing some APIs to escape the 255 character
	limit of Win32 paths.
	'''
	if platform.system() == 'Windows':
		if path.startswith('\\\\?'):
			return path
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
	
	if verbose:
		print("Removing " + fn)
		
	if dryrun:
		return
	
	if platform.system() == 'Windows':
		try:
			os.remove(fn)
		except WindowsError as e:
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
				if ctypes.windll.kernel32.SetFileAttributesW(str(fn), FILE_ATTRIBUTE_NORMAL) == 0:
					errno = ctypes.windll.kernel32.GetLastError()
					raise Exception('SetFileAttributesW failed with error code {0}'.format(errno))
				os.remove(fn)
			else:
				raise
	else:
		os.remove(fn)

def removeFilesInDir(targetDir, keep_ext):
	'''
	Deletes all files in the given targetDir except
	the ones with extensions in the keep_ext list.
	Will recursively descend into subdirectories.
	'''
	for dirpath, dirnames, filenames in os.walk(targetDir):
		for fn in filenames:
			relFn = os.path.join(dirpath, fn)

			# Sometimes, people package up files with
			# non-ASCII encodings, like:
			# https://groups.google.com/forum/#!topic/boost-developers-archive/m4Uw5fhvgCE
			#
			# We have no way to know what
			# encoding the creator of the file
			# meant to use. So, we'll just avoid
			# touching non-ASCII files in here.
			try:
				asciiFn = relFn.encode('ascii')
			except:
				print('Skipped non-ASCII filename')
				continue

			absFn = makeAbs(relFn)

			# It seems that os.walk can't handle very long file names
			# too well. It gives us directories in the filenames list,
			# and doesn't walk the files in those directories.
			#
			# One such bad filename is, in Python syntax:
			# '\\\\?\\c:\\MumbleBuild\\win64-static-1.3.x-2014-12-23-b1ea927.build\\'
			#  + 'qt-everywhere-opensource-src-5.4.0\\qtwebengine\\src\\3rdparty\\'
			#  + 'chromium\\third_party\\WebKit\\Tools\\Scripts\\webkitruby\\'
			#  + 'check-for-inappropriate-macros-in-external-headers-tests\\'
			#  + 'resources\\Fake.framework\\Headers'
			#
			# As a workaround, we determine whether an entry in the filenames
			# list is in fact a directory, and if it is, we begin walking that
			# directory as well. At least that works.
			if os.path.isdir(absFn):
				removeFilesInDir(absFn, keep_ext=keep_ext)
				continue
			_, ext = os.path.splitext(fn.lower())
			if not ext[1:] in keep_ext:
				rm(absFn)

def main():
	global verbose
	global dryrun
	
	parser = argparse.ArgumentParser(description='Cleans up the <buildenv-name>.build directories that are used for storing source zips, tarballs and source trees when a build env is being built.')
	parser.add_argument('builddir', help='<buildenv-name>.build directory (e.g. c:/MumbleBuild/centos-ermine-1.2.x-2014-06-01-cf59267.build)')
	parser.add_argument('--dry-run', action='store_true')
	parser.add_argument('-v', '--verbose', action='store_true')
	parser.add_argument('--force' , action='store_true', help = 'Force run on directories not ending in .build')
	args = parser.parse_args();
	verbose = args.verbose
	dryrun = args.dry_run
	build_dir = args.builddir
	
	if verbose:
		print("Performing cleanup on " + build_dir)

	if dryrun:
		print("Performing dry run. No files will actually be deleted.")
	
	if not args.force:
		build_dirname =  os.path.basename(os.path.normpath(build_dir))
		if not build_dirname.endswith(".build"):
			print("Build directory name '" + build_dirname + "' does not end in .build . If you are sure you want to clean this path re-execute with --force")
			sys.exit(1)
	
	# Perform initial cleanup
	if verbose:
		print("Performing initial cleanup")

	removeFilesInDir(build_dir, keep_ext=KEEP_EXT)

	if verbose:
		print("Done with initial cleanup")
	
	# After that perform additional cleanup
	if verbose:
		print("Performing additional cleanup")

	patterns = [os.path.join(build_dir, g) for g in ADDITIONAL_CLEANUP]
	for pattern in patterns:
		for p in glob.glob(pattern):
			if os.path.isfile(p):
				rm(p)
			elif os.path.isdir(p):
				removeFilesInDir(p, keep_ext=[])
				
	if verbose:
		print("Done with additional cleanup")
	
if __name__ == '__main__':
	main()
