#!/bin/bash -ex
eval "echo -e \"$(<ermine.conf.in)\"" > ${MUMBLE_PREFIX}/etc/ermine.conf
install -m 0755 ../../tools/dump-ermine-elfs.py ${MUMBLE_PREFIX}/bin/dump-ermine-elfs.py
install -m 0755 ../../tools/zero-ermine-ld.py ${MUMBLE_PREFIX}/bin/zero-ermine-ld.py
