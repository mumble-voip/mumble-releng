#!/usr/bin/env python
# -*- coding: utf-8

# Copyright (C) 2013 Stefan Hacker <dd0t@users.sourceforge.net>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:

# - Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# - Neither the name of the Mumble Developers nor the names of its
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.

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

from subprocess import call
from logging import basicConfig, DEBUG, INFO, WARNING, ERROR, debug, error, info, warning, exception
import sys
import os
import json
import msilib
import tempfile
from glob import glob
from shutil import copy, rmtree
from argparse import ArgumentParser

default_config_path = r"C:\dev\mumble-releng\buildenv\windows\config.json"

def collect(args):
    debug("Source: %s", args.source)
    debug("Target: %s", args.target)
    debug("7z.exe: %s", args.sevenZip)
    
    info("Collecting symbols from '%s' into '%s'", args.source, args.target)
    
    buildfile = 'build.json'

    buildinfo = {"type" : args.buildtype,
                 "version" : args.version,
                 "product" : args.product }

    debug("Writing buildinfo to '%s', content: %s", buildfile, repr(buildinfo))
    
    try:
         json.dump(buildinfo, open(os.path.join(args.source, buildfile), "w"),
                   indent = 4, separators = (',',' : '))
    except Exception, e:
        error("Could not write info file to '%s'", os.path.join(args.source, buildfile))
        exception(e)
        return 2
    
    debug('Done')
    debug('Call 7z for compression')
    abstarget = os.path.abspath(args.target)
    
    # Calls 7z.exe to collect and compress. Parameters:
    #    a        Create archive
    #    -bd      Don't display progress
    #    -r       Recursively descend
    #    <arch>   Archive name
    #    <what>   What to add to archive
    #
    result = call([args.sevenZip, 'a', '-bd', '-r', abstarget, "*.exe", "*.pdb", "*.dll", buildfile], cwd = args.source)
    if result == 0:
        info('Done')
    else:
        error('Failed %d', result)
        
    return result

def updateFromMSI(args):
    debug("Archive: %s", args.archive)
    debug("Target: %s", args.target)
    debug("msi: %s", args.msi)
    debug("7z.exe: %s", args.sevenZip)

    info("Replacing binaries in '%s' from '%s'", args.archive, args.msi)

    msidir = tempfile.mkdtemp()
    archdir = tempfile.mkdtemp()
    try:
        debug("Reading '%s' msi database", args.msi)
        
        msidb = msilib.OpenDatabase(args.msi, msilib.MSIDBOPEN_READONLY)
        
        # Reference:
        #   http://msdn.microsoft.com/en-us/library/windows/desktop/aa368596%28v=vs.85%29.aspx
        # A helpful tool for looking into an msi can be found at:
        #   http://code.google.com/p/lessmsi/
        
        view = msidb.OpenView("SELECT File, FileName FROM File")
        view.Execute(None)
        msifiles = {} # Original filename -> MSI filename mapping
        try:
            while True:
                row = view.Fetch()
                if not row: break
                rowFile = row.GetString(1) # Not 0 based
                rowFileNames = row.GetString(2).split('|') # Short and long filename are seperated by |
                if len(rowFileNames) > 1:
                    longRowFileName = rowFileNames[1]
                    msifiles[longRowFileName] = rowFile
                else:
                    shortRowFileName = rowFileNames[0]
                    msifiles[shortRowFileName] = rowFile
        except msilib.MSIError, e:
            # Unfortunately this always happens when we reach the end while fetching
            # 0x103 is ERROR_NO_MORE_ITEMS, no idea why we get that as an exception
            # instead of a None on Fetch
            if not e.message == 'unknown error 103':
                raise
            pass
        debug("Done")
        
        debug("Extract '%s' msi file", args.msi)
        result = call([args.sevenZip, 'e', '-bd', '-o' + msidir, args.msi])
        if result != 0:
            error("Failed to extract msi '%d'", result)
            return result
        debug("Done")
        
        debug("Extract '%s' archive file", args.archive)
        result = call([args.sevenZip, 'x', '-bd', '-o' + archdir, args.archive])
        if result != 0:
            error("Failed to extract archive '%d'", result)
            return result
        debug("Done")
        
        debug("Replacing binary files")
        for (dirpath, dirnames, filenames) in os.walk(archdir):
            for filename in filenames:
                if os.path.splitext(filename)[1] in ['.exe', '.dll']:
                    # Check for replacement in flat msi directory
                    msifilename = msifiles.get(filename)
                    if msifilename:
                        msifile = os.path.join(msidir, msifilename)
                        archfile = os.path.join(dirpath, filename)
                        debug("Replacing '%s' with '%s'", filename, msifilename)
                        copy(msifile, archfile)
                    else:
                        warning("Found no replacement match for '%s'", filename)
        debug("Done")
        
        debug("Re-packing archive")
        abstarget = os.path.abspath(args.target)
        # Since we started with an archive to begin with and only performed replacements
        # no filtering is needed
        result = call([args.sevenZip, 'a', '-bd', '-r', abstarget], cwd = archdir)
        if result != 0:
            error("Failed to re-pack archive from '%s' to '%s'", archdir, args.target)
            return result
        debug("Done")
            
    finally:
        rmtree(msidir)
        rmtree(archdir)

    return 0

def updateFromZIP(args):
    debug("Archive: %s", args.archive)
    debug("Target: %s", args.target)
    debug("Zip: %s", args.zip)
    debug("7z.exe: %s", args.sevenZip)
    
    info("Replacing binaries in '%s' from '%s'", args.archive, args.zip)

    zipdir = tempfile.mkdtemp()
    archdir = tempfile.mkdtemp()
    try:
        debug("Extract '%s' zip file", args.zip)
        result = call([args.sevenZip, 'e', '-bd', '-o' + zipdir, args.zip])
        if result != 0:
            error("Failed to extract zip '%d'", result)
            return result
        debug("Done")
        
        # Map file basenames from the ZIP to their paths
        # relative to zipdir.
        zipfiles={}
        for (dirpath, dirnames, filenames) in os.walk(zipdir):
            rel = dirpath.replace(zipdir, '')
            if len(rel) > 0 and rel[0] == '\\':
                rel = rel[1:]
            for fn in filenames:
                basefn = os.path.basename(fn)
                zipfiles[basefn] = os.path.join(rel, basefn)

        debug("Extract '%s' archive file", args.archive)
        result = call([args.sevenZip, 'x', '-bd', '-o' + archdir, args.archive])
        if result != 0:
            error("Failed to extract archive '%d'", result)
            return result
        debug("Done")
        
        debug("Replacing binary files")
        for (dirpath, dirnames, filenames) in os.walk(archdir):
            for filename in filenames:
                if os.path.splitext(filename)[1] in ['.exe', '.dll']:
                    zipfilename = zipfiles.get(filename)
                    if zipfilename:
                        zipfile = os.path.join(zipdir, zipfilename)
                        archfile = os.path.join(dirpath, filename)
                        debug("Replacing '%s' with '%s'", filename, zipfilename)
                        copy(zipfile, archfile)
                    else:
                        warning("Found no replacement match for '%s'", filename)
        debug("Done")
        
        debug("Re-packing archive")
        abstarget = os.path.abspath(args.target)
        # Since we started with an archive to begin with and only performed replacements
        # no filtering is needed
        result = call([args.sevenZip, 'a', '-bd', '-r', abstarget], cwd = archdir)
        if result != 0:
            error("Failed to re-pack archive from '%s' to '%s'", archdir, args.target)
            return result
        debug("Done")
            
    finally:
        rmtree(zipdir)
        rmtree(archdir)

    return 0

if __name__ == "__main__":
    CI = 'CI'
    SNAPSHOT = 'Snapshot'
    BETA = 'Beta'
    RC = 'RC'
    RELEASE = 'Release'

    BUILD_TYPES = [CI, SNAPSHOT, BETA, RC, RELEASE]
    
    parent_parser = ArgumentParser(description = 'Collects and updates symbol archives to feed into the symbolstore')
    subparsers = parent_parser.add_subparsers(help = 'action', dest='action')
    
    collect_parser = subparsers.add_parser('collect', help = 'Collect symbols from build folder')
    collect_parser.add_argument('source', help = 'Folder root to collect symbols from')
    collect_parser.add_argument('target', help = 'Target archive')
    collect_parser.add_argument('--version', help = 'Build version', required = True)
    collect_parser.add_argument('--buildtype', help = 'Build type', choices = BUILD_TYPES, required = True)
    collect_parser.add_argument('--product', help = 'Build product', required = True)
    
    collect_parser = subparsers.add_parser('update', help = 'Replace binary files in archive with ones from the msi')
    collect_parser.add_argument('archive', help = 'Source archive')
    collect_parser.add_argument('--target', help = 'Target archive')
    collect_parser.add_argument('--msi-or-zip', help = '.msi or .zip to retrieve binaries from', dest = 'msi_or_zip')
    
    parent_parser.add_argument('-c', '--config', help = 'Mumble buildenv config.json file', default = default_config_path)
    parent_parser.add_argument('-v', '--verbose', help = 'Verbose logging', action='store_true')
    parent_parser.add_argument('-7', '--7zip', help = 'Path to 7z.exe', dest = 'sevenZip')

    args = parent_parser.parse_args()
    
    basicConfig(level = (DEBUG if args.verbose else INFO))
    
    if not args.sevenZip:
        try:
            config = json.load(open(args.config))
        except Exception, e:
            error("Failed to load Mumble buildenv configuration file from '%s'", args.config)
            exception(e)
            sys.exit(1)

        if not args.sevenZip:
            args.sevenZip = config["_7zip"]["exe"]

    if args.action == 'collect':
        retval = collect(args)
    elif args.action == 'update':
        matches = glob(args.msi_or_zip)
        if not matches:
            error("Could not find MSI or ZIP file with glob '%s'", args.msi_or_zip)
            sys.exit(1)
        if len(matches) > 1:
            error("Too many files passed via --msi-or-zip: '%s'", matches)
            sys.exit(1)
        match = matches[0]
        if match.lower().endswith('.zip'):
            args.zip = match
            retval = updateFromZIP(args)
        elif match.lower().endswith('.msi'):
            args.msi = match
            retval = updateFromMSI(args)
        else:
            error("File passed in via --msi-or-zip is neither an MSI file nor a ZIP file")
            exit(1)
    else: assert(False)
    
    sys.exit(retval)
