dracutmoddir = @X_DATADIR@/dracut/modules.d/95nbd9

# N.B. targets named 'install' and 'check' confuse automake - avoid them
install-data-local:
	-$(top_srcdir)/config/install-sh -m 755 \
		xinstall $(DESTDIR)$(dracutmoddir)/install
	-$(top_srcdir)/config/install-sh -m 755 \
		xcheck   $(DESTDIR)$(dracutmoddir)/check 
	-$(top_srcdir)/config/install-sh -m 755 \
		installkernel $(DESTDIR)$(dracutmoddir)/installkernel
	-$(top_srcdir)/config/install-sh -m 755 \
		parse-9nbdroot.sh $(DESTDIR)$(dracutmoddir)/parse-9nbdroot.sh
	-$(top_srcdir)/config/install-sh -m 755 \
		9nbdroot $(DESTDIR)$(dracutmoddir)/9nbdroot

EXTRA_DIST = xcheck xinstall installkernel 9nbdroot parse-9nbdroot.sh
