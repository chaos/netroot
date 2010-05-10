Name: nfsroot
Version: 0
Release: 0
Source:
License: GPL
Summary: Configuration and scripts for diskless NFS root.
Group: Applications/Devel
BuildArch: noarch
Requires: dhclient, net-tools, iproute, gawk, bash, util-linux
Requires: findutils, module-init-tools, pciutils, which, file
Requires: rsync, genisoimage, nfs-utils, gzip, cpio, tar
Requires: kexec-tools, kernel
Requires(post): /sbin/chkconfig
Requires(preun): /sbin/chkconfig

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}

%description
Configuration and scripts for diskless NFS root.

%prep
%setup -q -n %{name}-%{version}

%build

%install
rm -rf ${RPM_BUILD_ROOT}
mkdir -p ${RPM_BUILD_ROOT}/etc
mkdir -p ${RPM_BUILD_ROOT}/sbin
mkdir -p ${RPM_BUILD_ROOT}/usr/share/nfsroot
mkdir -p ${RPM_BUILD_ROOT}/etc/sysconfig
mkdir -p ${RPM_BUILD_ROOT}%{_initrddir}
mkdir -p ${RPM_BUILD_ROOT}/boot
mkdir -p ${RPM_BUILD_ROOT}/isolinux
mkdir -p ${RPM_BUILD_ROOT}%{_mandir}/man8

install rc.nfsroot-aufs         ${RPM_BUILD_ROOT}/etc/
install rc.nfsroot-unionfs      ${RPM_BUILD_ROOT}/etc/
install rc.nfsroot-bind         ${RPM_BUILD_ROOT}/etc/
install rc.nfsroot-rbind        ${RPM_BUILD_ROOT}/etc/
install rc.nfsroot-kdump        ${RPM_BUILD_ROOT}/etc/
install rc.nfsroot-ram          ${RPM_BUILD_ROOT}/etc/
install rc.nfsroot-none         ${RPM_BUILD_ROOT}/etc/
install rc.nfsroot              ${RPM_BUILD_ROOT}/etc/

install nfsroot.init            ${RPM_BUILD_ROOT}%{_initrddir}/nfsroot

install configpxe               ${RPM_BUILD_ROOT}/sbin/
install mkinitrd_nfsroot        ${RPM_BUILD_ROOT}/sbin/
install nfsroot-kernel-pkg      ${RPM_BUILD_ROOT}/sbin/
install mklivecd                ${RPM_BUILD_ROOT}/sbin/

install -m 0644 mkinitrd_nfsroot.8   ${RPM_BUILD_ROOT}%{_mandir}/man8/
install -m 0644 configpxe.8     ${RPM_BUILD_ROOT}%{_mandir}/man8/
install -m 0644 mklivecd.8      ${RPM_BUILD_ROOT}%{_mandir}/man8/

install initrd-init             ${RPM_BUILD_ROOT}/usr/share/nfsroot/
install -m 0644 nfsrootfun.sh   ${RPM_BUILD_ROOT}/usr/share/nfsroot/
install -m 0644 initial-fstab   ${RPM_BUILD_ROOT}/usr/share/nfsroot/
install -m 0644 profile         ${RPM_BUILD_ROOT}/usr/share/nfsroot/

install -m 0644 sysconfig.nfsroot \
                                ${RPM_BUILD_ROOT}/etc/sysconfig/nfsroot
install -m 0644 sysconfig.network \
                                ${RPM_BUILD_ROOT}/etc/sysconfig/network

install -m 0644 pxelinux.cfg    ${RPM_BUILD_ROOT}/boot/
install -m 0644 pxelinux.msg    ${RPM_BUILD_ROOT}/boot/
install -m 0755 pxelinux.0-3.11 ${RPM_BUILD_ROOT}/boot/pxelinux.0
install -m 0644 isolinux.cfg    ${RPM_BUILD_ROOT}/isolinux
install -m 0644 isolinux.msg    ${RPM_BUILD_ROOT}/isolinux
install -m 0755 isolinux.bin-3.11 ${RPM_BUILD_ROOT}/isolinux/isolinux.bin

mkdir -p 0755 ${RPM_BUILD_ROOT}/writeable

%clean
rm -rf ${RPM_BUILD_ROOT}

%post
if ! [ -c /dev/console ]; then
    rm -f /dev/console 
    mknod -m 600 /dev/console c 5 1
fi
if ! [ -c /dev/null ]; then
    rm -f /dev/null
    mknod -m 666 /dev/null c 1 3
fi
if ! [ -c /dev/rtc ]; then
    rm -f /dev/rtc
    mknod -m 644 /dev/rtc c 10 135
fi
/sbin/chkconfig --add nfsroot
/sbin/nfsroot-kernel-pkg -A
if ! [ -f /etc/fstab ]; then
    install -m 644 /usr/share/nfsroot/initial-fstab /etc/fstab
fi

%preun
if [ "$1" = "0" ]; then
   /sbin/chkconfig --del nfsroot
fi

%files
%defattr(-,root,root)
%doc README
%doc NEWS
%doc ChangeLog
%doc dhcpd.conf
%config(noreplace) /etc/sysconfig/nfsroot
%config(noreplace) /etc/sysconfig/network
%config(noreplace) /boot/pxelinux.cfg
%config(noreplace) /boot/pxelinux.msg
%config(noreplace) /isolinux/isolinux.cfg
%config(noreplace) /isolinux/isolinux.msg
/boot/pxelinux.0
/isolinux/isolinux.bin
/etc/rc.nfsroot
/etc/rc.nfsroot-aufs
/etc/rc.nfsroot-unionfs
/etc/rc.nfsroot-none
/etc/rc.nfsroot-bind
/etc/rc.nfsroot-rbind
/etc/rc.nfsroot-kdump
/etc/rc.nfsroot-ram
/usr/share/nfsroot
/sbin/mkinitrd_nfsroot
/sbin/configpxe
/sbin/nfsroot-kernel-pkg
/sbin/mklivecd
%{_initrddir}/nfsroot
%{_mandir}/man8/*
%dir /writeable

%changelog
* Mon Jun 19 2006 Jim Garlick <garlick@llnl.gov>
- Created
