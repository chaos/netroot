Name: nfsroot
Version: 3.5
Release: 1
Source0: %{name}-%{version}.tar.gz
License: GPL
Summary: Diskless Boot Support
Group: Applications/System

Requires: genisoimage
Requires: syslinux
Requires: memtest86+ = 4.00
Requires: dracut-network
Requires: rsync, nfs-utils, gzip, cpio, tar kexec-tools, kernel

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}

%define bootdir /boot

%description
Diskless boot support.

%prep
%setup -q -n %{name}-%{version}

%build
%configure
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
if ! [ -f %{_sysconfdir}/fstab ]; then
    install -m 644 %{_datadir}/nfsroot/initial-fstab %{_sysconfdir}/fstab
fi
rm -f %{bootdir}/pxelinux.0 %{bootdir}/memdisk
install -m 644 %{_datadir}/syslinux/pxelinux.0 %{bootdir}/
install -m 644 %{_datadir}/syslinux/memdisk    %{bootdir}/
mkdir -p -m 755 /writeable
%{_sbindir}/nfsroot-rebuild

%files
%defattr(-,root,root)
%doc README
%doc NEWS
%doc ChangeLog
%config(noreplace) %{_sysconfdir}/sysconfig/nfsroot
%config(noreplace) %{bootdir}/pxelinux.cfg
%config(noreplace) %{bootdir}/pxelinux.msg
%{bootdir}/freedos.img
%{_sysconfdir}/rc.nfsroot*
%{_datadir}/nfsroot
%{_sbindir}/*
%{_mandir}/man8/*
%{_sysconfdir}/dracut.conf.d/*
%{_datadir}/dracut/modules.d/*
%{_sysconfdir}/kernel/postinst.d/*
%{_sysconfdir}/kernel/prerm.d/*

%changelog
* Mon Jun 19 2006 Jim Garlick <garlick@llnl.gov>
- Created
