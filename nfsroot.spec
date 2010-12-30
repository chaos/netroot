Name: nfsroot
Version: 0
Release: 0
Source:
License: GPL
Summary: Diskless Boot Support
Group: Applications/System
BuildRequires: syslinux
BuildRequires: memtest86+

Requires(post): /sbin/chkconfig
Requires(preun): /sbin/chkconfig


BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}

%description
Diskless boot support.

%package base
Summary: Diskless Boot Support Base
Group: Applications/System
%description base
Diskless boot support, common stuff.

%package nfs
Summary: Diskless Boot Support - NFS
Group: Applications/System
Requires: nfsroot-base
Requires: dhclient, net-tools, iproute, gawk, bash,
Requires: util-linux findutils, module-init-tools, pciutils, which, file
Requires: rsync, nfs-utils, gzip, cpio, tar kexec-tools, kernel
%description nfs
Diskless boot support, NFS-specific stuff.

%package livecd
Summary: Diskless Boot Support - LivcCD
Requires: nfsroot-base
Requires: dhclient, net-tools, iproute, gawk, bash,
Requires: util-linux findutils, module-init-tools, pciutils, which, file
Requires: rsync, nfs-utils, gzip, cpio, tar kexec-tools, kernel
Requires: genisoimage
%description livecd
Diskless boot support, LiveCD-specific stuff.

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
install -m 0755 %{_datadir}/syslinux/pxelinux.0 \
				${RPM_BUILD_ROOT}/boot/pxelinux.0
install -m 0755 %{_datadir}/syslinux/memdisk \
				${RPM_BUILD_ROOT}/boot/memdisk
install -m 0755 /boot/memtest86+-* \
				${RPM_BUILD_ROOT}/boot/memtest86+
install -m 0755 img/freedos.img ${RPM_BUILD_ROOT}/boot/freedos.img

install -m 0644 isolinux.cfg    ${RPM_BUILD_ROOT}/isolinux
install -m 0644 isolinux.msg    ${RPM_BUILD_ROOT}/isolinux
install -m 0755 %{_datadir}/syslinux/isolinux.bin \
				${RPM_BUILD_ROOT}/isolinux/isolinux.bin
install -m 0755 %{_datadir}/syslinux/memdisk \
				${RPM_BUILD_ROOT}/isolinux/memdisk
install -m 0755 img/freedos.img ${RPM_BUILD_ROOT}/isolinux/freedos.img
install -m 0755 /boot/memtest86+-* \
				${RPM_BUILD_ROOT}/isolinux/memtest86+

mkdir -p 0755 ${RPM_BUILD_ROOT}/writeable

%clean
rm -rf ${RPM_BUILD_ROOT}

%post nfs
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

%preun nfs
if [ "$1" = "0" ]; then
   /sbin/chkconfig --del nfsroot
fi

%files base
%defattr(-,root,root)
%doc README
%doc NEWS
%doc ChangeLog
%doc dhcpd.conf
%config(noreplace) %{_sysconfdir}/sysconfig/nfsroot
%config(noreplace) /boot/pxelinux.cfg
%config(noreplace) /boot/pxelinux.msg
/boot/pxelinux.0
/boot/freedos.img
/boot/memdisk
/boot/memtest86+
%{_sysconfdir}/rc.nfsroot*
%{_datadir}/nfsroot
/sbin/mkinitrd_nfsroot
/sbin/configpxe
/sbin/nfsroot-kernel-pkg
%{_mandir}/man8/configpxe.8*
%{_mandir}/man8/mkinitrd_nfsroot.8*
%dir /writeable

%files nfs
%defattr(-,root,root)
%config(noreplace) /etc/sysconfig/network
%{_initrddir}/nfsroot

%files livecd
%config(noreplace) /isolinux/isolinux.cfg
%config(noreplace) /isolinux/isolinux.msg
/sbin/mklivecd
%{_mandir}/man8/mklivecd.8*
/isolinux/isolinux.bin
/isolinux/freedos.img
/isolinux/memdisk
/isolinux/memtest86+

%changelog
* Mon Jun 19 2006 Jim Garlick <garlick@llnl.gov>
- Created
