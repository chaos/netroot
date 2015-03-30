#!/bin/sh
#
# Preferred format:
#	root=nbd9:srv:imgpath[:fstype[:rootflags[:nbdopts]]]
#	[root=*] netroot=nbd9:srv:imgpath[:fstype[:rootflags[:nbdopts]]]
#
# nbdopts is a comma seperated list of options to give to mount.diod
#
# root= takes precedence over netroot= if root=nbd9[...]
#

# Sadly there's no easy way to split ':' separated lines into variables
netroot_to_var() {
    local v=${1}:
    set --
    while [ -n "$v" ]; do
        set -- "$@" "${v%%:*}"
        v=${v#*:}
    done

    unset server imgpath
    server=$2; imgpath=$3
}

# This script is sourced, so root should be set. But let's be paranoid
[ -z "$root" ] && root=$(getarg root=)

if [ -z "$netroot" ]; then
    for netroot in $(getargs netroot=); do
        [ "${netroot%%:*}" = "nbd9" ] && break
    done
    [ "${netroot%%:*}" = "nbd9" ] || unset netroot
fi

# Root takes precedence over netroot
if [ "${root%%:*}" = "nbd9" ] ; then
    if [ -n "$netroot" ] ; then
	warn "root takes precedence over netroot. Ignoring netroot"

    fi
    netroot=$root
    unset root
fi

# If it's not nbd9 don't continue
[ "${netroot%%:*}" = "nbd9" ] || return

# Check required arguments
netroot_to_var $netroot
[ -z "$server" ] && die "Argument server for 9nbdroot is missing"
[ -z "$imgpath" ] && die "Argument imgpath for 9nbdroot is missing"

# 9NBD actually supported?
incol2 /proc/devices 9nbd || modprobe 9nbd || die "9nbd requested but kernel/initrd does not support it"

# Done, all good!
rootok=1

# Shut up init error check
if [ -z "$root" ]; then
    root=block:/dev/root
    wait_for_dev -n /dev/root
fi
