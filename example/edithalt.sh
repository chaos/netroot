#!/bin/bash

# issue 8: need /sbin/reboot to work with RHEL6

# this is scary and non-portable but it solves the problem for
# initscripts-9.03.17-1.el6.x86_64 at least

sed --in-place=.orig -e 's/\"tmpfs\" ||/\"DONTKILLtmpfs\" ||/g' /etc/init.d/halt
