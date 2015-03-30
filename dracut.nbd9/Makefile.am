dracutmoddir = @X_EXEC_PREFIX@/lib/dracut/modules.d/95nbd9

# N.B. targets named 'install' and 'check' confuse automake - avoid them
install-data-local:
	-$(top_srcdir)/config/install-sh -m 755 \
		module-setup.sh $(DESTDIR)$(dracutmoddir)/module-setup.sh
	-$(top_srcdir)/config/install-sh -m 755 \
		parse-nbd9root.sh $(DESTDIR)$(dracutmoddir)/parse-nbd9root.sh
	-$(top_srcdir)/config/install-sh -m 755 \
		munge-cleanup.sh $(DESTDIR)$(dracutmoddir)/munge-cleanup.sh
	-$(top_srcdir)/config/install-sh -m 755 \
		nbd9root.sh $(DESTDIR)$(dracutmoddir)/nbd9root.sh

EXTRA_DIST = \
	nbd9root.sh \
	parse-nbd9root.sh \
	munge-cleanup.sh \
	module-setup.sh
