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
from logging import basicConfig, getLogger, DEBUG, INFO, WARNING, ERROR, debug, error, info, warning, exception
import requests
import hashlib
from argparse import ArgumentParser
from xml.etree import ElementTree
from datetime import datetime
import os
import pefile
import git
import re
import struct
from shutil import copy, rmtree
from glob import glob

def retrievePdbFrom(name, guid, symbolserver):
    """
    Retrieves the given name from the symbolserver and places it in cache.
    Will fetch and extract compressed pdb versions if possible.
    
    Returns true if pdb was successfully retrieved and cached.
    """
    # Try fetching compressed version
    debug("Trying to fetch '%s' with GUID %s from '%s'", name, guid, symbolserver)
    
    # What we currently have cached is outdated or non-existent, delete it
    # so we don't clutter up the cache with stuff we'll never use again over time.
    rmtree(cachePath(name + '.pdb'), ignore_errors = True   )
    
    basedir = cachePath(os.path.join(name + '.pdb', guid))
    
    if not os.path.exists(basedir):
        os.makedirs(basedir)

    basepath = os.path.join(basedir, name)
    pdbfile = basepath + ".pdb"
    
    baseurl = "%s%s.pdb/%s/%s" % (symbolserver, name, guid, name) # e.g. http://symbols.hacst.net/wow.pdb/574B0A708DAB4B91AFD1BACF71D427691/
    result = requests.get(baseurl + ".pd_")
    if result.ok:
        # Write and decompress
        pdfile = basepath + ".pd_"
        debug("Writing '%s' to '%s' [compressed]", result.url, pdfile)
        with open(pdfile, 'wb') as f:
            f.write(result.content)
            
        debug("Decompressing '%s' to '%s'", pdfile, pdbfile)
        if extractCab(pdfile, pdbfile) != 0:
            # Failed
            raise Exception("Failed to extract '%s' to '%s'" % (pdfile, pdbfile))
        
        # Done
        return True
    
    # Try uncompressed
    result = requests.get(baseurl + ".pdb")
    if not result.ok:
        # Couldn't find it in this store
        return False

    debug("Writing '%s' to '%s'", result.url, pdbfile)
    with open(pdbfile, 'wb') as f:
        f.write(result.content)
        
    return True

def retrievePdb(name, guid):
    """
    Attempts to retrieve the pdb from the known symbol servers.
    
    Returns true if the pdb was retrieved and is now in cache.
    """
    symbolservers = ['http://symbols.hacst.net/', 'http://mumble.info:8080/symbols/']
    
    for symbolserver in symbolservers:
        if retrievePdbFrom(name, guid, symbolserver):
            return True
    
    return False
    
def getSymbolserverPdbGUID(filename):
    """
    Assembles the GUID used by symstore for symbolserver paths
    from the debug information in a plugins PE header and returns it.
    
    If no GUID can be extracted, the function returns None.
    """
    path = cachePath(filename)
    
    pe = pefile.PE(path)
    
    # Find the CodeView entry in the PE file's debug directory.
    header = None
    for entry in getattr(pe, 'DIRECTORY_ENTRY_DEBUG', []):
        dbgtype = entry.struct.Type
        if pefile.DEBUG_TYPE.get(dbgtype) == 'IMAGE_DEBUG_TYPE_CODEVIEW':
            header = entry.struct
            break
    if header is None:
        debug('Unable to find IMAGE_DEBUG_TYPE_CODEVIEW in DIRECTORY_ENTRY_DEBUG. Returning None.')
        return None
    
    data = pe.get_data(header.AddressOfRawData, header.SizeOfData)
    
    # http://www.debuginfo.com/articles/debuginfomatch.html
    #
    #struct CV_INFO_PDB70
    #{
    #  DWORD  CvSignature;
    #  GUID Signature;
    #  DWORD Age;
    #  BYTE PdbFileName[];
    #} ;
    # http://reboot.pro/topic/13937-fetching-a-pdb-from-microsoft/
    #
    # PdbSig70 structure is L2H8B, if we hexify it and attach age we
    # have the directory filename of the pdb on the symbol server. Compare
    # to dhb.exe (Windows debugging tools) info command.
    
    CV_INFO_PDB70 = struct.Struct('<4sL2H8BB')
    elements = CV_INFO_PDB70.unpack_from(data)
    
    cvsig = elements[0]
    pdbsig70 = elements[1:-1]
    age = elements[-1]
    pdb = data[CV_INFO_PDB70.size:]
    
    guid = ("{:08X}" + 2 * "{:04X}" + 8 * "{:X}").format(*pdbsig70) + "{:X}".format(age)

    debug("%s has a pdb guid of %s (original pdb: '%s')", filename, guid, pdb)
    
    return guid

def extractCab(cab, dll):
    null = open(os.devnull,"w")
    return call(["expand", cab, dll], stdout = null)

def cachePath(path):
    return os.path.join(args.plugincache, path)

def buildPath(path = ''):
    return os.path.join(args.pluginoutputdir, path)

def getPluginList(ver = '1.2.4', os='Win32', abi='1600'):
    """
    Returns an Element tree of the XML returned by the public plugins.php
    for the given parameters.
    """
    res = requests.get("http://mumble.info:8080/plugins.php", params = {'ver' : ver,
                                                                        'os' : os,
                                                                        'abi' : abi})
    if not res.ok:
        raise Exception("Failed to download list from '%s'" % res.url)
    
    return ElementTree.fromstring(res.text)
    
def isCached(filename, hash):
    """
    Returns true if the given file is in cache and its hash
    matches the given one.
    """
    path = cachePath(filename)
    if not os.path.exists(path):
        return False
    
    return hash == hashlib.sha1(open(path, 'rb').read()).hexdigest()

def cachePlugin(filename, fullpath=None):
    """
    Downloads the given file from the public plugin server
    into the replacement cache.
    
    By default, this fetches the plugin from the Mumble
    services host at http://mumble.info:8080/plugins/<filename>.
    However, if fullpath is specified, the fullpath is used when
    fetching the plugin instead: https://mumble.info:8080/<fullpath>.
    """
    path = cachePath(filename)
    
    url = 'http://mumble.info:8080'
    if fullpath is not None:
        url += fullpath
    else:
        url += '/plugins/' + filename

    res = requests.get(url)
    if not res.ok:
        raise Exception("Failed to fetch '%s'" % res.url)
    
    with open(path, 'wb') as f:
        f.write(res.content)
        
def collectPluginCreationDates(limitTo = None):
    """
    Makes sure the local cache contains all old plugin
    versions and collects their creation dates.
    
    The return value is a tuple consisting of the oldest
    creation datetime of all plugins and a dict of dll name
    to creation date mappings.
    """
    creation_dates = {}
    oldest = None
    
    info("Collecting plugin creation dates")
    plugins = getPluginList(ver = args.version, os = args.os, abi = args.abi)
    for plugin in plugins.findall('plugin'):
        name = plugin.attrib['name']
        hash = plugin.attrib['hash']
        path = plugin.attrib.get('path', None)
        
        if not name.endswith('.dll') or not hash:
            debug("Skipping '%s'", name)
            continue
        
        if limitTo != None and name not in limitTo:
            warning("Ignoring remotely available '%s'", name)
            continue
        
        if not isCached(name, hash):
            info("Retrieving '%s'", name)
            cachePlugin(name, path)
            assert(isCached(name, hash))
        
        created = getCreationDate(name)
        debug("Checking if '%s' has been modified since %s", name, created)
        creation_dates[name] = created
        if not oldest or created < oldest:
            oldest = created
    
    return (oldest, creation_dates)

def determineUnchangedPlugins(oldest, creation_dates):
    """
    Checks the repository history for changes to the
    plugins cpp/pro file. If such changes are found and
    they are newer than the creation date of the plugin
    it is assumed the plugin needs to be updated.
    """
    info("Checking repo for new revisions")
    
    old_plugins_to_use = creation_dates.copy()
    repo = git.Repo(args.repo)
    
    pluginmatch = re.compile(r'^plugins/(\w+)/')
    
    for commit in repo.iter_commits(rev = args.rev, paths = 'plugins/'):
        if not old_plugins_to_use:
            # Matched all
            break
        
        commit_date = datetime.fromtimestamp(commit.committed_date)
        if oldest > commit_date:
            # Checked all relevant commits
            break
        
        changed_files = commit.stats.files.keys()
        for changed in changed_files:
            match = pluginmatch.match(changed)
            if not match:
                continue
            
            name = match.group(1)
            dllname = name + ".dll"
            creation_date = old_plugins_to_use.get(dllname)
            if not creation_date:
                continue
            
            if commit_date > creation_date:
                info("Plugin '%s' has been updated in %s (%s)", name, commit.hexsha, commit_date)
                del old_plugins_to_use[dllname]
                
    return old_plugins_to_use

def copyUnchangedPluginsToBuild(old_plugins):
    """
    Copies dll and pdb for each plugin in the given dllname:creationtime dict
    to the plugin build output folder.
    """
    # Everything in old_plugins needs to be retained
    for dll, date in sorted(old_plugins.iteritems()):
        info("Re-using '%s' created on %s", dll, date)
        
        guid = getSymbolserverPdbGUID(dll)
        if guid is None:
            # Skip copying any files of plugins we don't have symbols for. That
            # way we will automatically upload new versions for plugins that were
            # accidently built without debug symbols.
            warning("Could not extract GUID for %s (missing debug info in PE file?), will not touch build version", dll)
            continue

        name = os.path.splitext(dll)[0]
        pdbname = name + ".pdb"
        cabname = name + ".pd_"
        # Check if we have that cached
        pdbpath = cachePath(os.path.join(pdbname, guid, pdbname))
        if not os.path.exists(pdbpath):
            info("Retrieving pdb with GUID %s for %s", guid, dll)
            
            if not retrievePdb(name, guid):
                # Skip copying any files of plugins we don't have symbols for. That
                # way we will automatically upload new versions for plugin for which
                # the store has lost its symbols.
                warning("Could not retrieve pdb with GUID %s for %s, will not touch build version", guid, name)
                continue
        
        # Overwrite build .pdb
        copy(pdbpath, buildPath())
        
        # Overwrite build .dll
        copy(cachePath(dll), buildPath())
        
def getCreationDate(filename):
    """
    Returns the PE header TimeDateStamp timestamp as a datetime
    """
    path = cachePath(filename)
    
    pe = pefile.PE(path)
    return datetime.fromtimestamp(pe.FILE_HEADER.TimeDateStamp)
    
def getLocalPluginNames():
    """
    Returns the list of .dll files in the plugins folder.
    """
    return [os.path.basename(f) for f in glob(buildPath('*.dll'))]
    
if __name__ == "__main__":
    parent_parser = ArgumentParser(description = 'Replaces newly compiled plugins with old versions if no actual code change happened')
    parent_parser.add_argument('pluginoutputdir', help = "Build output directory for plugins")
    
    parent_parser.add_argument('--version', help = 'Mumble version for plugins.php query', default = '1.3.0')
    parent_parser.add_argument('--os', help = 'OS for plugins.php query', default = 'Win32')
    parent_parser.add_argument('--abi', help = 'ABI version for plugins.php query', default = '1800')
    
    parent_parser.add_argument('--repo', help = 'Path to mumble repository', default = r'C:\dev\mumble')
    parent_parser.add_argument('--rev', help = 'Rev/Branch in repository to check for modification dates', default = None)
    parent_parser.add_argument('--plugincache', help = 'Path to cache directory for plugin files', default = r'c:\dev\plugin_replacement_cache')
    
    parent_parser.add_argument('-v', '--verbose', help = 'Verbose logging', action='store_true')

    args = parent_parser.parse_args()    
    basicConfig(level = (DEBUG if args.verbose else INFO))
    
    debug("Configuration: %s", repr(args))
    
    getLogger('requests').setLevel(WARNING)

    if not os.path.exists(args.plugincache):
        os.makedirs(args.plugincache)
    
    local_plugins = getLocalPluginNames()
    oldest, creation_dates = collectPluginCreationDates(limitTo = local_plugins)
    old_plugins = determineUnchangedPlugins(oldest, creation_dates)
    copyUnchangedPluginsToBuild(old_plugins)
        
    info("Done")
