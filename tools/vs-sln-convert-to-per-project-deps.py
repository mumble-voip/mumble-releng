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

# vs-sln-convert-to-per-project-deps.py
#
# What is it?
# -----------
#
# This script takes a pre-MSVS10 (Visual Studio 2010) solution file
# that contains dependency information, and converts that into per-project
# dependencies in .vcxproj files.
#
# Why's that useful?
# ------------------
#
# The Express edition of Visual Studio does not contain the ability to do
# a "devenv.exe /upgrade" to upgrade solution files; it merely contains
# vcupgrade.exe, which is only able to upgrade single project files
# from .vcproj -> .vcxproj.
#
# With some finesse, one can pretty much convert a Visual Studio 2008 or 2005
# solution + corresponding project files to a format that Visual Studio 2010
# is happy with -- *except* for the fact that Visual Studio 2010 now expects
# dependency information to be specified on a per-project basis, inside the
# .vcxproj files.
#
# In what context is this used?
# -----------------------------
#
# To perform a full conversion of a Visual Studio 2005 project (say), one would
# do the following (presented from the point of view of a Unix shell):
#
#  1)
#  # First, change the version information of the .sln to match
#  # the wanted Visual Studio version. Also, rename all references
#  # for .vcproj files to refer to .vcxproj files instead.
#  sed -i -re 's/Format Version 9.00/Format Version 11.00/g;
#                 s/Visual Studio 2005/Visual Studio 2010/g;
#                 s/\.vcproj/\.vcxproj/g;' protobuf.sln
#
#  2)
#  # Convert all .vcproj files referenced by the solution
#  # to the .vcxproj format.
#  for fn in `ls *.vcproj`; do
#    cmd /c vcupgrade.exe ${fn}
#  done
#
#  3)
#  At this point, everything should, in theory, work well.
#  Except for the fact that vcupgrade.exe cannot perform
#  migration of dependency information from the .sln file
#  to per-project deps, because it only works on a single
#  .vcproj at a time.
#
#  That's where this Python script comes in.  It expects
#  that steps 1 and 2 above have been executed, and can
#  update the newly-upgraded .vcxproj files with per-project
#  dependency information by migrating it from the .sln file.
#
#  # Upgrade all .vcxproj files referenced by protobuf.sln
#  # to have per-project dependency information.
#  python vs-add-project-deps.py protobuf.sln

from __future__ import (unicode_literals, print_function, division)

import sys
import re
import collections
import io

# Project represents a Project from a .sln file.
Project = collections.namedtuple('Project', ['solution_uuid', 'name', 'path', 'uuid', 'deps'])

# Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "libprotoc", "libprotoc.vcxproj", "{B84FF31A-5F9A-46F8-AB22-DBFC9BECE3BE}"
project_re = re.compile('''^Project\("\{([0-9A-Z\-]+)}"\) = "(.*)", "(.*)", "{([0-9A-Z\-]+)}"$''')

# ProjectSection(ProjectDependencies) = postProject
project_section_re = re.compile('''^\t*ProjectSection\((.*)\) = (.*)$''')

# {B84FF31A-5F9A-46F8-AB22-DBFC9BECE3BE} = {B84FF31A-5F9A-46F8-AB22-DBFC9BECE3BE}
project_deps_uuid_mapping_re = re.compile('''^\t*{([0-9A-Z\-]+)} = {([0-9A-Z\-]+)}$''')

def parseProjectDeps(f, m):
	'''
		parseProjectDeps parses a ProjectSection(ProjetctDependencies) section.
	'''
	deps = []

	while True:
		line = f.readline()
		if len(line) == 0: # EOF
			raise Exception('unexpected EOF in parseProjectDeps')

		m = project_deps_uuid_mapping_re.match(line)
		if m:
			uuid, uuid2 = m.groups()
			deps.append(uuid)

		if line.strip() == 'EndProjectSection':
			return deps

def parseProject(f, m):
	'''
		parseProject parses a Project({uuid}) section.
	'''
	solution_uuid, name, path, uuid = m.groups()
	deps = []

	while True:
		line = f.readline()
		if len(line) == 0: # EOF
			raise Exception('unxpected EOF in parseProject')

		m = project_section_re.match(line)
		if m:
			section_name, section_kind = m.groups()
			if section_name == 'ProjectDependencies':
				if section_kind != 'postProject':
					raise Exception('invalid section_kind encountered')
				deps = parseProjectDeps(f, m)

		if line.strip() == 'EndProject':
			return Project(solution_uuid, name, path, uuid, deps)

def projectsInSolution(slnPath):
	'''
		projectsInSolution parses the .sln file specified
		by slnPath and returns all the projects found inside
		it as instances of the Project namedtuple.
	'''
	projects = []

	f = io.open(slnPath, encoding='utf-8')
	while True:
		line = f.readline()
		if len(line) == 0: # EOF
			break

		m = project_re.match(line)
		if m:
			p = parseProject(f, m)
			projects.append(p)

	return projects

def depsToXML(project, uuid_mapping):
	'''
		depsToXML converts a project's dependencies to
		an ItemGroup XML hierarchy suitable for inclusion
		into a .vcxproj file.

		It maps UUIDs to projects using the given uuid_mapping.
	'''
	xml = '  <ItemGroup>\n'
	for dep in project.deps:
		dep_proj = uuid_mapping[dep]
		xml += '    <ProjectReference Include="%s">\n' % dep_proj.path
		xml += '      <Project>{%s}</Project>\n' % dep_proj.uuid
		xml += '      <ReferenceOutputAssembly>false</ReferenceOutputAssembly>\n'
		xml += '    </ProjectReference>\n'
	xml += '  </ItemGroup>\n'
	return xml

def main():
	if len(sys.argv) < 2:
		print('Usage: vs-sln-convert-to-per-project-deps.py <path-to-sln>')
		sys.exit(1)

	# Read all projects in the passed-in .sln file.
	solution = sys.argv[1]
	projects = projectsInSolution(solution)

	# Create a UUID -> Project mapping for use with
	# depsToXML.
	proj_uuid_mapping = {}
	for project in projects:
		proj_uuid_mapping[project.uuid] = project

	# Go through all projects, and find those with
	# project dependencies.
	#
	# Convert all project dependencies found in the
	# pre-VS10.0 solution file to per-project dependencies
	# embedded in the .vcxproj files.
	for project in projects:
		if len(project.deps) > 0:
			depsXML = depsToXML(project, proj_uuid_mapping)

			f = io.open(project.path, encoding='utf-8')
			s = f.read()
			f.close()

			end = '</Project>'
			actualEnd = s[-len(end):]
			if actualEnd != end:
				raise Exception('file does not end with </Project> tag')

			s = s[:-len(end)]
			f = io.open(project.path, 'w', encoding='utf-8')
			f.write(s)
			f.write(depsXML)
			f.write('</Project>')
			f.close()

if __name__ == '__main__':
	main()
