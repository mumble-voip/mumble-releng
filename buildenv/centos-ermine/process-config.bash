#!/bin/bash
set -e
eval "echo -e \"$(<ermine.conf.in)\"" > ${MUMBLE_PREFIX}/etc/ermine.conf
