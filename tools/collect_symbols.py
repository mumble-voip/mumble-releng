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
from argparse import ArgumentParser

default_config_path = r"C:\dev\mumble-releng\buildenv\windows\config.json"

def collect(args):
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

if __name__ == "__main__":
    CI = 'CI'
    NIGHTLY = 'Nightly'
    BETA = 'Beta'
    RC = 'RC'
    RELEASE = 'Release'

    BUILD_TYPES = [CI, NIGHTLY, BETA, RC, RELEASE]
    
    parent_parser = ArgumentParser(description = 'Maintains a Mumble symbol store')
    parent_parser.add_argument('source', help = 'Folder root to collect symbols from')
    parent_parser.add_argument('target', help = 'Target archive')
    parent_parser.add_argument('--version', help = 'Build version', required = True)
    parent_parser.add_argument('--buildtype', help = 'Build type', choices = BUILD_TYPES, required = True)
    parent_parser.add_argument('--product', help = 'Build product', required = True)
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
    
    debug("Source: %s", args.source)
    debug("Target: %s", args.target)
    debug("7z.exe: %s", args.sevenZip)
    
    sys.exit(collect(args))