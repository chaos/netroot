#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

check() {
    local _rootdev
    # If our prerequisites are not met, fail.
    type -P mount.diod >/dev/null || return 1

    # if an nbd device is not somewhere in the chain of devices root is
    # mounted on, fail the hostonly check.
    [[ $hostonly ]] || [[ $mount_needs ]] && {
        is_nbd() { [[ -b /dev/block/$1 && $1 == 252:* ]] ;}

        _rootdev=$(find_root_block_device)
        [[ -b /dev/block/$_rootdev ]] || return 1
        check_block_and_slaves is_nbd "$_rootdev" || return 255
    }

    return 0
}

depends() {
    # We depend on network modules being loaded
    echo network rootfs-block
}

installkernel() {
    instmods 9nbd
}

install() {
    inst mount.diod
    inst diodls
    inst diodcat
    inst dioddate
    inst munged
    inst munge
    inst request-key
    inst keyctl
    inst base64
    inst_hook cmdline 90 "$moddir/parse-nbd9root.sh"
    inst_hook pre-pivot 90 "$moddir/munge-cleanup.sh"
    inst_script "$moddir/nbd9root.sh" "/sbin/nbd9root"
    dracut_need_initqueue
}

