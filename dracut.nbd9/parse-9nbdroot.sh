#!/bin/sh
#
# Preferred format:
#	root=9nbd:srv:imgpath[:fstype[:rootflags[:nbdopts]]]
#	[root=*] netroot=9nbd:srv:imgpath[:fstype[:rootflags[:nbdopts]]]
#
# nbdopts is a comma seperated list of options to give to mount.diod
#
# root= takes precedence over netroot= if root=9nbd[...]
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

# Don't continue if root is ok
[ -n "$rootok" ] && return

# This script is sourced, so root should be set. But let's be paranoid
[ -z "$root" ] && root=$(getarg root=)
[ -z "$netroot" ] && netroot=$(getarg netroot=)

# Root takes precedence over netroot
if [ "${root%%:*}" = "9nbd" ] ; then
    if [ -n "$netroot" ] ; then
	warn "root takes precedence over netroot. Ignoring netroot"

    fi
    netroot=$root
fi

# If it's not 9nbd we don't continue
[ "${netroot%%:*}" = "9nbd" ] || return

# Check required arguments
netroot_to_var $netroot
[ -z "$server" ] && die "Argument server for 9nbd is missing"
[ -z "$imgpath" ] && die "Argument imgpath for 9nbd is missing"

# NBD actually supported?
incol2 /proc/devices nbd || modprobe 9nbd || die "9nbd requested but kernel/initrd does not support it"

# Done, all good!
rootok=1

# Shut up init error check
[ -z "$root" ] && root="9nbd"

echo '[ -e /dev/root ]' > /initqueue-finished/9nbd.sh

