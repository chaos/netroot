dracutmoddir = @X_DATADIR@/dracut/modules.d/96xnfsroot

dracutmod_SCRIPTS = installkernel

dracutconfdir = $(sysconfdir)/dracut.conf.d

dracutconf_DATA = xnfsroot.conf

# N.B. targets named 'install' and 'check' confuse automake - avoid them
install-data-local:
	-$(top_srcdir)/config/install-sh -m 755 \
		xinstall $(DESTDIR)$(dracutmoddir)/install
	-$(top_srcdir)/config/install-sh -m 755 \
		xcheck   $(DESTDIR)$(dracutmoddir)/check 

EXTRA_DIST = xcheck xinstall installkernel xnfsroot.conf
