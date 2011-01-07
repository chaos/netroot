Name: nfsroot
Version: 3.3
Release: 1
Source0: %{name}-%{version}.tar.gz
License: GPL
Summary: Diskless Boot Support
Group: Applications/System
BuildRequires: syslinux

Requires: dhclient, net-tools, iproute, gawk, bash,
Requires: util-linux findutils, module-init-tools, pciutils, which, file
Requires: rsync, nfs-utils, gzip, cpio, tar kexec-tools, kernel
Requires: genisoimage
Requires: dracut-network

Requires(post): /sbin/chkconfig
Requires(preun): /sbin/chkconfig

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}


%define bootdir /boot
%define isolinuxdir /isolinux
%define rootsbindir /sbin

%description
Diskless boot support.

%prep
%setup -q -n %{name}-%{version}

%build
%configure --with-dracut
make


%install
rm -rf ${RPM_BUILD_ROOT}
make install DESTDIR=${RPM_BUILD_ROOT}

%clean
rm -rf ${RPM_BUILD_ROOT}

%post
PATH=/sbin:/usr/sbin:$PATH
test -c /dev/console || mknod -m 600 /dev/console c 5 1
test -c /dev/null    || mknod -m 666 /dev/null    c 1 3
test -c /dev/rtc     || mknod -m 644 /dev/rtc     c 10 135

chkconfig --add nfsroot
nfsroot-kernel-pkg -A
if ! [ -f %{_sysconfdir}/fstab ]; then
    install -m 644 %{_datadir}/nfsroot/initial-fstab %{_sysconfdir}/fstab
fi
mkdir -p -m 755 /writeable

%preun
if [ "$1" = "0" ]; then
    /sbin/chkconfig --del nfsroot
fi

%files
%defattr(-,root,root)
%doc README
%doc NEWS
%doc ChangeLog
%config(noreplace) %{_sysconfdir}/sysconfig/nfsroot
%config(noreplace) %{bootdir}/pxelinux.cfg
%config(noreplace) %{bootdir}/pxelinux.msg
%config(noreplace) %{isolinuxdir}/isolinux.cfg
%config(noreplace) %{isolinuxdir}/isolinux.msg
%{bootdir}/pxelinux.0
%{bootdir}/freedos.img
%{bootdir}/memdisk
%{isolinuxdir}/isolinux.bin
%{isolinuxdir}/freedos.img
%{isolinuxdir}/memdisk
%{isolinuxdir}/memtest86+-4.00
%{_sysconfdir}/rc.nfsroot*
%{_datadir}/nfsroot
%{rootsbindir}/*
%{_mandir}/man8/*
%{_initrddir}/nfsroot
%{_datadir}/dracut/modules.d/*

%changelog
* Mon Jun 19 2006 Jim Garlick <garlick@llnl.gov>
- Created
