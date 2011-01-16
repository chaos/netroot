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
%{_sbindir}/*
%{_mandir}/man8/*
%{_sysconfdir}/dracut.conf.d/*
%{_datadir}/dracut/modules.d/*
%{_sysconfdir}/kernel/postinst.d/*
%{_sysconfdir}/kernel/prerm.d/*

%changelog
* Mon Jun 19 2006 Jim Garlick <garlick@llnl.gov>
- Created
