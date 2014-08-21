*nfsroot* is a package designed to help make Linux root file system
images network-bootable and sharable by many clients.  It was designed
for the CHAOS Linux distribution (now renamed to TOSS) for clusters,
developed at Lawrence Livermore National Laboratory, but will work with
other Red Hat Enterprise Linux derived distros.

*nfsroot* distinguishes itself from other tools for managing diskless
clusters by restricting itself to things that can be done by a package
installed within the root image, e.g.:

* management of initramfs images in /boot (leveraging dracut) and
pxelinux boot options
* making a shared, read-only root file system usable using selectable
methods (unionfs, aufs, bind-mounts, etc)
* hook for saving kdump vmcore images to NFS
* hook for configuration management before init starts 

The goal is that one can install the *nfsroot* RPM into a root image
and presto, it becomes bootable and sharable given appropriate server
configuration.

*nfsroot* leaves the root server configuration and configuration management
within the image to your superior mental prowess.  This minimalist design
is intended for sites (like ours) that already have procedures and
techniques in place for managing these subsystems and don't want a
diskless solution to help.

*nfsroot version 4* will run on TOSS 3  (RHEL 7 based), _in development_.

*nfsroot version 3* runs on CHAOS 5/TOSS 2  (RHEL 6 based), _feature-frozen_.

*nfsroot version 2* ran on CHAOS 4/TOSS 1 (RHEL 5 based), _end-of-life_.

*nfsroot version 1* ran on CHAOS 3 (RHEL 4 based), _end-of-life_.

