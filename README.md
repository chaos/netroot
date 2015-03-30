### netroot

*netroot* is a package of utilities for network root file systems.
It was designed for the TOSS Linux distribution for clusters, developed
at Lawrence Livermore National Laboratory, but will work with other
Red Hat Enterprise Linux derived distros.

*netroot* distinguishes itself from other tools for managing diskless
clusters by restricting itself to things that can be done by a package
installed within the root image, namely `/boot` management and dracut
modules.  It does not concern itself with other aspects such as
server-side setup and configuration management.  This minimalist design
is intended for sites (like ours) that already have procedures and
techniques in place for managing these subsystems and want a focused
diskless solution.

### support

Please open any issues in the *netroot* github issue tracker.

### history

*netroot* is derived from the [nfsroot](https://github.com/chaos/nfsroot)
project.  In RHEL 7, decent _stateless_ root support made *nfsroot*
unnecessary to support root over NFS; however we wanted to experiment with
root over [9nbd](https://github.com/chaos/9nbd), and retain the
rather handy `configpxe` scripts for managing `pxelinux.conf`
within the root image.

Hence *netroot* is a stripped down and renamed version of *nfsroot*,
ported to RHEL 7.
