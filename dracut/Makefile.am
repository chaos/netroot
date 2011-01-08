dracutmoddir = @X_DATADIR@/dracut/modules.d/96xnfsroot

dracutmod_SCRIPTS = installkernel

dracutconfdir = $(sysconfdir)/dracut.conf.d

dracutconf_DATA = xnfsroot.conf

postinstdir = /etc/kernel/postinst.d
postinst_SCRIPTS = nfsroot-postinst

prermdir = /etc/kernel/prerm.d
prerm_SCRIPTS = nfsroot-prerm

sbin_SCRIPTS = nfsroot-rebuild nfsroot-setdefault

# N.B. targets named 'install' and 'check' confuse automake - avoid them
install-data-local:
	-$(top_srcdir)/config/install-sh -m 755 \
		xinstall $(DESTDIR)$(dracutmoddir)/install
	-$(top_srcdir)/config/install-sh -m 755 \
		xcheck   $(DESTDIR)$(dracutmoddir)/check 

EXTRA_DIST = xcheck xinstall installkernel xnfsroot.conf nfsroot-postinst nfsroot-prerm
