#!/usr/bin/env python
#
# Copyright 2018 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# Dump a .squashfs file from an .AppImage.
#
# Sometimes, unsquashfs gets confused and can't find
# the superblock. We find it, via 'hsqs' header and
# major version == 4 and copy the squashfs filesystem
# to its own file.

from __future__ import (unicode_literals, print_function, division)

import os
import sys

def usage():
	print('dump-appimage.py <appimage-fn>')
	print('')
	print('Writes resulting .squashfs file to')
	print('<appimage-fn>.squashfs.')
	sys.exit(1)

def main():
	if len(sys.argv) < 2:
		usage()
	fn = sys.argv[1]
	f = open(fn, 'r')
	all = f.read()
	f.close()

	squashMagic = bytearray((ord('h'), ord('s'), ord('q'), ord('s')))
	squashOffset = 0
	squashMajor = 0
	for i in range(0, len(all)):
		if all[i:i+len(squashMagic)] == squashMagic:
			squashOffset = i
			squashMajor = (ord(all[i+29]) << 8) | ord(all[i+28])
			if squashMajor == 4:
				break

	if squashOffset == 0 or squashMajor != 4:
		raise Exception('no squashfs image found')

	newf = open(fn + '.squashfs', 'w')
	newf.write(all[i:])
	newf.close()

if __name__ == '__main__':
	main()
