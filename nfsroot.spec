Name: nfsroot
Version: 3.24
Release: 1
Source0: %{name}-%{version}.tar.gz
License: GPL
Summary: Diskless Boot Support
Group: Applications/System

Requires: syslinux
Requires: memtest86+
Requires: dracut-network
Requires: rsync, nfs-utils, gzip, cpio, tar, kexec-tools, kernel
# Requires: munge keyutils diod 1.0.15 kmod-v9fs
Requires(post): syslinux

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
if ! [ -e %{_sysconfdir}/fstab ]; then
   install -m 644 %{_datadir}/nfsroot/initial-fstab %{_sysconfdir}/fstab
fi

%files
%defattr(-,root,root)
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
%{_datadir}/nfsroot

%changelog
* Mon Jun 19 2006 Jim Garlick <garlick@llnl.gov>
- Created
