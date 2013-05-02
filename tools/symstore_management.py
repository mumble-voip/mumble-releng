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
import os
import sys
import time
import json
import datetime
import tempfile
from shutil import rmtree
from itertools import ifilter
from argparse import ArgumentParser


default_config_path = r"C:\dev\mumble-releng\buildenv\windows\config.json"

def index(path, recursive = False):
    """
    Returns files in given directory or path itself if a file is given.
    [] if path is neither a file or directory.
    """
    if os.path.isfile(path):
        return [path]
    
    if not os.path.isdir(path):
        warning("'%s' is neither a file nor a directory", path)
        return []
    
    result = []
    
    for root, dirs, files in os.walk(path):
        for file in files:
            result.append(os.path.join(root, file))
        
        if not recursive:
            break
            
    return result
            
class Symstore(object):
    def __init__(self, symstore_path, exe, sevenZip, history):
        assert(os.path.exists(symstore_path))
        assert(os.path.exists(exe))
        assert(os.path.exists(sevenZip))

        self.symstore_path = symstore_path
        self.exe = exe
        self.sevenZip = sevenZip
        self.history = history

    def symstore(self, command, parameters = []):
        return call([self.exe, command] + parameters)
    
    def doAddMany(self, paths,  product = "", version = "", comment = "", recursive = False):
        debug("symstore add Product: '%s' Version: '%s' Comment: '%s' Paths: '%s'", product, version, comment, paths)
        
        temp = tempfile.NamedTemporaryFile(delete = False)
        try:
            files = []
            for path in paths:
                inpath = index(path, recursive)
                debug("Adding %d files from '%s'", len(inpath), path)
                files.extend(inpath)

            temp.write(os.linesep.join(files))
            temp.file.close()
            
            # Prefixing an @ to the filename tells symstore to  expect a list of _file_ paths at that location
            result = self.doAdd('@' + temp.name, product, version, comment)
        finally:
            temp.file.close()
            os.remove(temp.name)
        
        return result
    
    def doAddArchive(self, path):
        tempdir = tempfile.mkdtemp()
        try:
            debug("Extracting '%s' to temporary directory '%s'", path, tempdir)

            result = call([self.sevenZip, 'x', '-bd', '-o' + tempdir, path])
            if result != 0:
                error("Failed to extract archive '%s' to '%s' (%d)", path, tempdir, result)
                return result

            metadata = json.load(open(os.path.join(tempdir, 'build.json')))

            type = metadata["type"]
            version = metadata["version"]
            product = metadata["product"]
            
            info("Adding '%s' build of '%s' in version '%s' to symbol store", type, product, version)
            return self.doAdd(tempdir, product, version, type, True)
        finally:
            rmtree(tempdir)

        return 1

    def doAdd(self, path, product = "", version = "", comment = "", recursive = False):
        debug("symstore add Product: '%s' Version: '%s' Comment: '%s' Path: '%s'", product, version, comment, path)
        
        params = ['/compress',
                  '/f', '%s' % path, # Path to file/directory to add
                  '/s', '%s' % self.symstore_path, # Path to symbol store root
                  '/t', '%s' % product, # Product
                  '/v', '%s' % version, # Product Version
                  '/c',  '%s' % comment] # Transaction comment
        
        return self.symstore("add", (['/r'] + params) if recursive else params)
    
    def doDel(self, revision):
        debug("symstore del Rev: %s", revision)

        # symstore.exe creates deletion transactions for non-existant
        # ill-formed transactions. Use the history to make sure the
        # transaction we want to delete actually exists
        try:
            assert(self.history[revision].type == 'add')
            assert(not self.history[revision].deleted)
        except:
            error("Revision %s not found in history, aborting." % revision)
            return 1
        
        params = ['/i', '%010d' % int(revision), # Revision/id
                  '/s', '%s' % self.symstore_path] # Path to symbol store root]
        
        return self.symstore("del", params)

class Rsync(object):
    def __init__(self, bash):
        # Cygwin bash
        assert(os.path.exists(bash))
        self.bash = bash
        
    def doSync(self, source, target):
        info("rsync syncing from '%s' to '%s'", source, target)
        
        # This calls rsync from the cygwin bash, CHERE_INVOKING=1 tells cywgin to not change
        # to the user home directory on startup but stay in the directory it is invoked from.
        # This way we don't have to mess with the windows source path to get it into cygwin.
        # The rsync command is parameterized as follows:
        #    -e ssh    Use ssh
        #    -v    Verbose, we want some debugging output
        #    -r    Recursive, we want to sync the whole tree
        #    -t    Transfer file-time information, we want to actually see if stuff is newer
        #    -p    Transfer file-permissions, need to be able to chmod (see below)
        #    --chmod... Makes rsync _send_ 750 permissions (required -p to work)
        #    .     cwd as source
        #    symbolserver:{target}    We expect a symbolserver user on the remote server that
        #                             can write to the targetpath.
        return call([self.bash,
              '--login',
              '-c',
              'rsync -e ssh -vrtp --chmod=u=rwx --chmod=g=rx --chmod=o= . symbolserver:%s' % target],
              env = {'CHERE_INVOKING':'1'},
              cwd = source)

class Maintainer(object):
    CI = 'CI'
    NIGHTLY = 'Nightly'
    BETA = 'Beta'
    RC = 'RC'
    RELEASE = 'Release'
    DEPENDENCY = 'Dependency'

    BUILD_TYPES = [CI, NIGHTLY, BETA, RC, RELEASE, DEPENDENCY]
    
    PRODUCT = 'Mumble'
    
    def __init__(self, history, symstore):
        self.history = list(history)
        self.symstore = symstore

        def pred(entry):
            """
            Only 'add' transactions can be worked with
            Only transactions that haven't been deleted yet should be considered
            Transactions not concerning our PRODUCT should be ignored
            """
            return (t.type == 'add') and (t.product == self.PRODUCT) and not t.isDeleted()
        
        self.add_history = list(ifilter(pred, reversed(self.history)))
    
    
    def performDeletions(self, what):
        for entry in what:
            if self.symstore.doDel(entry.transaction) != 0:
                error("Error while deleting transaction %d, abort", entry.transaction) 

    def getDeletions(self):
        """
        Get all entries the rules coded in this maintainer consider obsolete.
        
        NO ACTION IS PERFORMED IN THIS FUNCTION
        Use performDeletions(entries) to apply result to symstore
        """
        result = []
        result.extend(self.deletionsForCI())
        result.extend(self.deletionsForNightly())
        result.extend(self.deletionsForBeta())
        result.extend(self.deletionsForRC())
        result.extend(self.deletionsForRelease())
        
        # Return sorted by transaction id (descending)
        return sorted(result, cmp = lambda a,b: cmp(int(a.transaction), int(b.transaction)), reverse = True )
    
    
    def deletionsForCI(self):
        """
        Strategy: Keep last 100 entries.
        """
        return self._deletionsForEntriesAfterNthEntry(100, self.CI)
    
    def deletionsForNightly(self):
        """
        Strategy: Keep the last 6 Months ~ 6*4*7 entries.
        """
        return self._deletionsForEntriesAfterNthEntry(6*4*7, self.NIGHTLY)
    
    def deletionsForRC(self):
        """
        Strategy: Keep release candidates of the last five releases
        """
        return self._deletionsForEntriesBeforeNthRelease(5, self.RC)
    
    def deletionsForBeta(self):
        """
        Strategy: Keep betas of the last five releases
        """
        return self._deletionsForEntriesBeforeNthRelease(5, self.BETA)
    
    def deletionsForRelease(self):
        """
        Strategy: Never delete a release
        """
        return []
    
    def _deletionsForEntriesBeforeNthRelease(self, n, comment):
        result = []
        releases_seen = 0
        for entry in self.add_history:
            if entry.comment == self.RELEASE:
                releases_seen += 1
                continue
            
            if releases_seen < n or entry.comment != comment:
                continue
            
            result.append(entry)
        
        return result
    
    def _deletionsForEntriesAfterNthEntry(self, n, comment):
        result = []
        entries_seen = 0
        for entry in self.add_history:
            if entry.comment != comment:
                continue
            
            entries_seen += 1
            
            if entries_seen < n:
                continue
            
            result.append(entry)
            
        return result



class History(object):
    """
    Class for loading and interpreting the history.txt.
    http://msdn.microsoft.com/en-us/library/windows/desktop/ms681417%28v=vs.85%29.aspx
    """
    class Entry(object):
        def __init__(self, transaction, type):
            self.transaction = transaction
            self.type = type
            
    class EntryAdd(Entry):
        def __init__(self, transaction, datetime, product = "", version = "", comment = ""):
            History.Entry.__init__(self, transaction, 'add')
            self.transaction = transaction
            self.datetime = datetime
            self.product = product
            self.version = version
            self.comment = comment
            self.deleted = None
        
        def delete(self, transaction = True):
            self.deleted = transaction
            
        def isDeleted(self):
            return self.deleted
        
        def __repr__(self):
            return "%s\t%s\t'%s'\t'%s'\t'%s'\t'%s'" % (self.transaction,
                                          self.datetime,
                                          self.product,
                                          self.version,
                                          self.comment,
                                          ("(deleted in %s)" % self.deleted) if self.deleted else "")
    
    class EntryDel(Entry):
        def __init__(self, transaction, deleted):
            History.Entry.__init__(self, transaction, 'del')
            self.deleted = deleted
            
        def __repr__(self):
            return "%s deletes %s" % (self.transaction, self.deleted)
            
    def __init__(self, path = 'history.txt'):
        history_file = os.path.join(path, "000Admin", "history.txt")
        self.history = []
        
        cntAdd = 0
        cntDel = 0
        
        debug("Loading history from '%s'", path)
        with open(history_file, 'r') as f:
            for transactionstring in f:
                fields = transactionstring.strip().split(',')
                
                transaction = fields[0]
                type = fields[1]
                
                if type == 'add':
                    assert(fields[2] == 'file')
                    dt = datetime.datetime.fromtimestamp(time.mktime(time.strptime(fields[3] + ' ' + fields[4], "%m/%d/%Y %H:%M:%S")))
                    product = fields[5][1:-1] if len(fields) > 5 else ""
                    version = fields[6][1:-1] if len(fields) > 6 else ""
                    comment = fields[7][1:-1] if len(fields) > 7 else ""
                    
                    entry = self.EntryAdd(transaction, dt, product, version, comment)
                    cntAdd += 1
                elif type == 'del':
                    deleted = fields[2]
                    entry = self.EntryDel(transaction, deleted)
                    self.history[int(deleted) - 1].delete(transaction)
                    cntDel +=1
                else:
                    assert(False)
                    
                self.history.append(entry)
                assert(int(entry.transaction) == len(self.history))
        debug("Loaded %d revisions (Add: %d, Del: %d, Active: %d)", cntAdd+cntDel, cntAdd, cntDel, cntAdd-cntDel)

    def pretty_print(self, pred = None):
        header = ["Transaction", "Type", "Date", "Product", "Version", "Build", "Comment"]
        listformat = "{:<14}{:<6}{:<22}{:<10}{:<23}{:<10}{:<22}"
        formatedheader = listformat.format(*header)
        info(formatedheader)
        info("=" * len(formatedheader))
        
        for entry in ifilter(pred, self.history):
            data = [entry.transaction,
                    entry.type,
                    str(getattr(entry, 'datetime', '')),
                    getattr(entry, 'product', ''),
                    getattr(entry, 'version', ''),
                    getattr(entry, 'comment', ''),
                    '' if not entry.deleted else ("Deleted %s" if entry.type == 'del' else "Deleted in %s") % entry.deleted 
                    ]
            info(listformat.format(*data))
            
    def __iter__(self):
        for h in self.history:
            yield h

    def __getitem__(self, key):
        res = self.history[key - 1]
        assert(key == int(res.transaction))
        return res

def actionAdd(args):
    try:
        history = History(args.store)
        store = Symstore(args.store, args.exe, args.sevenZip, history)
        return store.doAddMany(args.paths, args.product, args.version, args.buildtype, args.recursive)
    except Exception, e:
        error("Failed to add paths %s to symbol store", ', '.join(args.paths))
        exception(e)
        
    return 1

def actionAddArchive(args):
    try:
        history = History(args.store)
        store = Symstore(args.store, args.exe, args.sevenZip, history)
        return store.doAddArchive(args.archive)
    except Exception, e:
        error("Failed to add archive '%s' to symbol store", args.archive)
        exception(e)

    return 1
    
def actionDel(args):
    try:
        history = History(args.store)
        store = Symstore(args.store, args.exe, args.sevenZip, history)
        return store.doDel(args.transaction)
    except Exception, e:
        error("Failed to revert transaction '%s'", args.transaction)
        exception(e)

    return 1

def actionList(args):
    try:
        history = History(args.store)
    except Exception, e:
        error("Failed to load history for store at '%s'", args.store)
        exception(e)
        return 1
    
    def filter(x):
        if args.type is not None:
            if not args.type == x.type:
                return False
            
        if x.type != 'add':
            return True # Later filters do not apply
        
        if args.product is not None:
            if not args.product == x.product:
                return False
            
        if args.version is not None:
            if not args.version == x.version:
                return False
            
        if args.buildtype is not None:
            if not args.buildtype == x.comment:
                return False
            
        return True
    
    history.pretty_print(filter)
    
    return 0

def actionSync(args):
    try:
        rsync = Rsync(args.bash)
        return rsync.doSync(args.store, args.remote)
    except Exception, e:
        error("Failed to sync '%s' to '%s'", args.store, args.remote)
        exception(e)

    return 1

if __name__ == "__main__":
    parent_parser = ArgumentParser(description = 'Maintains a Mumble symbol store')
    subparsers = parent_parser.add_subparsers(help = 'action', dest='action')
    
    add_parser = subparsers.add_parser('add', help = 'Add to symbol store')
    add_parser.add_argument('--version', help = 'Version to store as', required = True)
    add_parser.add_argument('--buildtype', help = 'Build type to store as', choices = Maintainer.BUILD_TYPES, required = True)
    add_parser.add_argument('--product', help = 'Product to store as', required = True)
    add_parser.add_argument('--recursive', help = 'Recursive import', action='store_true')
    add_parser.add_argument('paths', metavar = 'path', nargs='+', help = 'Path to import')

    add_archive = subparsers.add_parser('add-archive', help = 'Add a archive to the symbol store')
    add_archive.add_argument('archive', help = 'Symbol archive to add')
    
    del_parser = subparsers.add_parser('del', help = 'Delete a transaction from the symbol store')
    del_parser.add_argument('transaction', type=int, help = 'ID of transaction to reverse')

    list_parser = subparsers.add_parser('list', help = 'List contents of symbol store')
    list_parser.add_argument('--product', help = 'Only show transactions from given product')
    list_parser.add_argument('--version', help = 'Only show transactions of given version')
    list_parser.add_argument('--buildtype', help = 'Only show transaction of given build type', choices = Maintainer.BUILD_TYPES)
    list_parser.add_argument('--type', help = 'Only show transactions of given type', choices = ['add', 'del'])
    
    parent_parser.add_argument('--log', help = 'Logfile to log to')
    parent_parser.add_argument('--config', help = 'Mumble buildenv config.json file', default = default_config_path)
    parent_parser.add_argument('-v', '--verbose', help = 'Verbose logging', action='store_true')
    parent_parser.add_argument('--store', help = 'Path to symbol store')
    parent_parser.add_argument('--exe', help = 'Path to symstore.exe')
    parent_parser.add_argument('--7zip', help = 'Path to 7z.exe', dest = 'sevenZip')
    parent_parser.add_argument('--bash', help = 'Path to bash.exe')
    parent_parser.add_argument('--logformat', help = 'Format for python logging facility', default = '%(message)s')
    
    sync_parser = subparsers.add_parser('sync', help = 'Sync symstore to remote site')
    sync_parser.add_argument('remote', help = 'URI for symbol store sync site')

    args = parent_parser.parse_args()
    
    basicConfig(level = (DEBUG if args.verbose else INFO), format = args.logformat)
    
    if not (args.store and args.exe and args.sevenZip and args.bash):
        try:
            config = json.load(open(args.config))
        except Exception, e:
            error("Failed to load Mumble buildenv configuration file from '%s'", args.config)
            exception(e)
            sys.exit(1)
        
        if not args.store:
            args.store = config["symstore"]["root"]
        if not args.exe:
            args.exe = config["symstore"]["exe"]
        if not args.sevenZip:
            args.sevenZip = config["_7zip"]["exe"]
        if not args.bash:
            args.bash = os.path.join(config["cygwin"]["root"], r"bin\bash.exe")
    
    debug("Symstore: %s", args.store)
    debug("symstore.exe: %s", args.exe)
    debug("7z.exe: %s", args.sevenZip)
    debug("bash.exe: %s", args.bash)
    
    if args.action == 'list':
        retval = actionList(args)
    elif args.action == 'add-archive':
        retval = actionAddArchive(args)
    elif args.action == 'add':
        retval = actionAdd(args)
    elif args.action == 'sync':
        retval = actionSync(args)
    elif args.action == 'del':
        retval = actionDel(args)
    else: assert(False)
    
    sys.exit(retval)
    