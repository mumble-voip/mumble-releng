#!/usr/bin/env python
# -*- coding: utf-8
#
# Copyright 2014-2016 The 'mumble-releng' Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that
# can be found in the LICENSE file in the source tree or at
# <http://mumble.info/mumble-releng/LICENSE>.

# buildenv-status.py generates a HTML status report for
# all the buildenvs in mumble-releng.
#
# This is to aid in buildenv maintenance.
#
# This script is intended to give maintainers a
# birds's-eye view of all recipes in all buildenvs,
# in order to keep track of things like versions,
# patches, etc. -- across build environments.
#
# The current version of the script is rather crude,
# but is still a great help.

from __future__ import (unicode_literals, print_function, division)

import io
import os
import re
import subprocess

class Buffer(object):
	'''
		Buffer wraps an array/string-like object and provides
		getch, putch and skip methods.
	'''

	def __init__(self, data):
		self.data = data
		self.idx = 0

	def getch(self):
		'''
			Get the character at the current buffer index.
		'''
		ch = self.data[self.idx]
		self.idx += 1
		return ch

	def putch(self, ch):
		'''
			Put a character back into the buffer.
			As a self-test, the character that is put back
			must match the character that getch returned
			for the given index.
		'''
		self.idx -= 1
		assert(ch == self.data[self.idx])
		pass

	def skip(self, n):
		'''
			Skip n characters of the buffer.
		'''
		for i in range(0, n):
			self.getch()

class Buildenv(object):
	'''
		Buildenv represents a Mumble build environment.
	'''

	def __init__(self, path):
		'''
			Construct a Buildenv

			The path argument must point to the root directory
			of the build environment.
		'''
		self.root = path
		self.name = os.path.basename(self.root)
		self.version = os.path.basename(os.path.dirname(self.root))
		self.full_name = "{0}/{1}".format(self.version, self.name)

		self._read_recipes()
		pass

	def _read_recipes(self):
		'''
			Parse all recipes in the Buildenv.
		'''
		all_files = os.listdir(self.root)
		recipe_fns = [os.path.join(self.root, fn) for fn in all_files if fn.lower().endswith(".build")]
		self.recipes = [Recipe(fn) for fn in recipe_fns]

	def lookup_recipe(self, name):
		'''
			Look up a recipe by name.
			
			Returns a Recipe if successful.

			Returns None on failure.
		'''
		for recipe in self.recipes:
			if recipe.name == name:
				return recipe
		return None

class Recipe(object):
	'''
		Recipe represents a recipe in a Mumble build environment.
	'''

	def __init__(self, path):
		'''
			Construct and parse the Recipe.
		'''
		self.path = path
		self._read()

		fn = os.path.basename(path)
		self.name = fn.replace(".build", "")

		self.urls = self._read_string_array("urls=(")
		self.digests = self._read_string_array("digests=(")

		self.vet_function = self._read_function("function vet {")
		self.fetch_function = self._read_function("function fetch {")
		self.verify_function = self._read_function("function verify {")
		self.extract_function = self._read_function("function extract {")
		self.prepare_function = self._read_function("function prepare {")
		self.build_function = self._read_function("function build {")
		self.testsuite_function = self._read_function("function testsuite {")
		self.install_function = self._read_function("function install {")

		self.version = self._guess_version()

	def _read(self):
		'''
			Read the whole recipe into memory as self.data
		'''
		with io.open(self.path, "r", encoding="utf-8") as f:
			s = f.read()
			self.data = s

	def _get_buffer_after(self, needle):
		'''
			_get_buffer_after finds needle in self.data
			and returns a buffer from the index of needle
			to the end of the file.
		'''
		idx = self.data.find(needle)
		if idx == -1:
			return None
		buf = Buffer(self.data[idx:])
		buf.skip(len(needle))
		return buf

	def _is_whitespace(self, ch):
		'''
			is_whitespace returns True if ch is a whitespace character
			in the context of a build recipe.
		'''
		return ch == " " or ch == "\t" or ch == "\n"

	def _read_comment(self, buf):
		'''
			_read_comment consumes a line comment from buf.

			It expects that the #-character has already been read.

			It does not return the comment.
		'''
		while True:
			ch = buf.getch()
			if ch == "\n":
				break

	def _read_string_literal(self, buf):
		'''
			_read_string_literal reads a string literal from buf.

			It expects that the "-character has already been read.

			It returns the string literal that was read.
		'''
		literal = u""
		while True:
			ch = buf.getch()
			if ch == "\\":
				nextCh = buf.getch()
				if nextCh == "\"":
					literal += nextCh
				else:
					buf.putch(nextCh)
					literal += ch
				continue
			elif ch == "\"":
				break
			else:
				literal += ch

		return literal

	def _read_here_doc(self, buf):
		'''
			_read_here_doc reads a here document.

			A here document is a construct of the type:

			    <<EOF
			    	this is a here
			    	document in a
			    	unix shell
			    EOF

			The here document is merely consumed, and
			nothing is returned.
		'''
		here_doc_buffer_view = buf.data[buf.idx:]
		
		end_of_delimiter_index = here_doc_buffer_view.find("\n")
		if end_of_delimiter_index == -1:
			raise Exception("expected delimiter")

		full_delimiter = here_doc_buffer_view[:end_of_delimiter_index]
		stripped_delimiter = full_delimiter.strip()
		if "\"" in stripped_delimiter:
			raise Exception("quoted delimiters are unsupported inside heredocs")
		delimiter = stripped_delimiter

		rest_of_here_doc = here_doc_buffer_view[end_of_delimiter_index:]
		end_of_here_doc = rest_of_here_doc.find(delimiter)

		buf.skip(end_of_here_doc + len(delimiter))

	def _read_string_array(self, start_of_declaration):
		'''
			_read_string_array reads a string array from
			a build recipe.

			A string array looks like:

			    name=("string literal" "other string literal")

			A list of strings containing the content of the string
			array is returned.
		'''
		strings = []
		buf = self._get_buffer_after(start_of_declaration)
		if buf is None:
			return strings

		while True:
			ch = buf.getch()
			if self._is_whitespace(ch):
				continue
			if ch == "#":
				self._read_comment(buf)
			elif ch == "\"":
				literal = self._read_string_literal(buf)
				strings.append(literal)
				continue
			elif ch == ")":
				break
			else:
				raise Exception("unexpected character {0} ({1}) in string array".format(ch, ord(ch)))

		return strings

	def _read_function(self, start_of_declaration):
		'''
			_read_function reads a Bash function.

			A function looks like:

			    function name {
			       # function body goes here
			    }

			This function reads a whole function and returns
			its literal representation (such as what is shown
			in the example above) as a string.
		'''
 		# The goal is to find the end of the function
		# declaration.
		buf = self._get_buffer_after(start_of_declaration)
		if buf is None:
			return None

		level = 1 # number of levels of "{}" we're deep

		while True:
			ch = buf.getch()
			if self._is_whitespace(ch):
				continue
			if ch == "#":
				self._read_comment(buf)
			elif ch == "\"":
				self._read_string_literal(buf)
			elif ch == "<":
				nextCh = buf.getch()
				if nextCh == "<":
					self._read_here_doc(buf)
				else:
					buf.putch(nextCh)
			elif ch == "{":
				level += 1
			elif ch == "}":
				level -= 1
				if level == 0:
					break

		return buf.data[0:buf.idx]

	def _fn_for_url(self, url):
		''''
			_fn_for_url returns the filename that should be used for a given URL.

			Mumble build recipes are allowed to specify a #fn=<filname>
			suffix on URLs.

			This is to allow recipes to specify "proper" filenames
			for URLs that do not include them.

			If a "#fn="-suffix is present in the URL, the filename returned
			from this function is the one specified in there.

			Otherwise, the basename of the URL is returned as the filename.
		'''
		needle = "#fn="
		idx = url.find(needle)
		if idx != -1:
			return url[idx+len(needle):]
		else:
			return os.path.basename(url)

	def _full_pkg_name_from_fn(self, fn):
		'''
			_full_pkg_name_from_fn returns the
			full package name of the given filename.

			That is, a name and a version, combined.
			The file extension is removed.

			For example: zlib-1.2.8.
		'''
		pkgname = fn
		pkgname = pkgname.replace(".zip", "")
		pkgname = pkgname.replace(".tgz", "")
		pkgname = pkgname.replace(".tar.gz", "")
		pkgname = pkgname.replace(".tar.bz2", "")
		pkgname = pkgname.replace(".tar.xz", "")
		pkgname = pkgname.replace(".tar.lzma", "")
		pkgname = pkgname.replace(".7z", "")
		pkgname = pkgname.replace(".msi", "")
		return pkgname

	def _split_pkg_name_and_version(self, full_pkg_name):
		'''
			_split_pkg_name_and_version takes a full package
			name as returned by _full_pkg_name_from_fn and
			returns a tuple of (pkg_name, version).

			The function contains some heuristics for
			finding the version number for packages that
			don't use the normal naming scheme ("<pkg>-<version>").
		'''
		if "boost" in full_pkg_name.lower():
			first_dash_index = full_pkg_name.find("_")
			if first_dash_index == -1:
				raise Excpetion("unable to read boost version")
			pkg_name = full_pkg_name[:first_dash_index-1]
			boost_style_version = full_pkg_name[first_dash_index+1:]
			version = boost_style_version.replace("_", ".")
			return (pkg_name, version)

		if full_pkg_name.endswith("-src"):
			full_pkg_name = full_pkg_name.replace("-src", "")

		if full_pkg_name.endswith("-x86"):
			full_pkg_name = full_pkg_name.replace("-x86", "")

		if full_pkg_name.endswith("-win32"):
			full_pkg_name = full_pkg_name.replace("-win32", "")

		# Strawberry Perl
		if full_pkg_name.endswith("-64bit-portable"):
			full_pkg_name = full_pkg_name.replace("-64bit-portable", "")

		last_dash_index = full_pkg_name.rfind("-")
		if last_dash_index == -1:
			return (full_pkg_name, "0.0.0")

		pkg_name = full_pkg_name[:last_dash_index-1]
		version = full_pkg_name[last_dash_index+1:]
		return (pkg_name, version)

	def _guess_version(self):
		'''
			_guess_version fills out the self.version member variable.

			It attempts to guess a version from the recipe's URLs.
		'''
		for url in self.urls:
			fn = self._fn_for_url(url)
			full_pkg_name = self._full_pkg_name_from_fn(fn)
			_, version = self._split_pkg_name_and_version(full_pkg_name)
			return version
		return "0.0.0"

def html_escape(s):
	'''
		html_escape HTML escapes the string s.
	'''
	return s.replace("<", "&lt;").replace(">", "&gt;")

def mumble_releng_version():
	foo = subprocess.Popen(("git", "rev-list", "HEAD", "--count"), stdout=subprocess.PIPE)
	count, _ = foo.communicate()
	count = count.decode("utf-8")
	count = count.strip()

	bar = subprocess.Popen(("git", "log", "-n", "1", "--date=short", "--pretty=%ad-%h-{0}".format(count)), stdout=subprocess.PIPE)
	name, _ = bar.communicate()
	name = name.decode("utf-8")
	name = name.strip()

	baz = subprocess.Popen(("git", "status", "--porcelain"), stdout=subprocess.PIPE)
	dirty, _ = baz.communicate()
	dirty = dirty.decode("utf-8")
	dirty = dirty.strip()

	if len(dirty) > 0:
		name = "{0}~dirty".format(name)

	return name

def main():
	buildenvs = (
		Buildenv(os.path.join("buildenv", "1.2.x", "win32")),
		Buildenv(os.path.join("buildenv", "1.2.x", "osx")),
		Buildenv(os.path.join("buildenv", "1.2.x", "osx-universal")),
		Buildenv(os.path.join("buildenv", "1.2.x", "centos-ermine")),

		Buildenv(os.path.join("buildenv", "1.3.x", "win32-static")),
		Buildenv(os.path.join("buildenv", "1.3.x", "osx")),
		Buildenv(os.path.join("buildenv", "1.3.x", "osx-universal")),
		Buildenv(os.path.join("buildenv", "1.3.x", "centos-ermine"))
	)

	all_recipe_names = set()
	for buildenv in buildenvs:
		for recipe in buildenv.recipes:
			all_recipe_names.add(recipe.name)

	all_recipe_names_sorted = sorted(list(all_recipe_names))

	version = mumble_releng_version()
	fn = "buildenv-status-{0}.html".format(version)

	with io.open(fn, "w", encoding="utf-8") as html:
		html.write("<html>\n")
		html.write("<head>\n")
		html.write("<style>\n")
		html.write('''
			table {
				border: 1px solid black;
			}
			td {
				width: 200px; 
				border: 1px solid black;
			}
		''')
		html.write("</style>\n")
		html.write("</head>\n")
		html.write("<body>\n")
		html.write("<h1>{0}</h1>".format(html_escape(version)))

		for recipe_name in all_recipe_names_sorted:
			html.write("<h2>{0}</h2>\n".format(html_escape(recipe_name)))
			html.write("<table>\n")

			for buildenv in buildenvs:
				html.write(" <tr>\n")
				html.write("  <td>{0}</td>".format(html_escape(buildenv.full_name)))
				recipe = buildenv.lookup_recipe(html_escape(recipe_name))
				if recipe is not None:
					html.write("  <td>{0}</td>".format(html_escape(recipe.version)))
				else:
					html.write("  <td></td>\n")
				html.write(" </tr>\n")

			html.write("</table>\n")

		html.write("</body>")
		html.write("</html>")

	print("Wrote {0}".format(fn))

if __name__ == "__main__":
	main()
