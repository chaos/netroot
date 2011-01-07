SUBDIRS = boot configpxe etc freedos mklivecd rc

if WITH_DRACUT
SUBDIRS += dracut
else
SUBDIRS += mkinitrd
endif

rpmdirs:
	mkdir -p $(top_builddir)/rpm/SPECS
	mkdir -p $(top_builddir)/rpm/SOURCES
	mkdir -p $(top_builddir)/rpm/BUILD
	mkdir -p $(top_builddir)/rpm/RPMS
	mkdir -p $(top_builddir)/rpm/SRPMS

rpm: dist rpmdirs
	rpmbuild -ta --define "_topdir $(realpath $(top_builddir)/rpm)" $(DIST_ARCHIVES)

TESTROOT=/tftpboot/images/bokbagok
test:
	sudo rpm -r $(TESTROOT) -e nfsroot
	sudo rpm -r $(TESTROOT) -ivh rpm/RPMS/x86_64/nfsroot-*

EXTRA_DIST = DISCLAIMER META nfsroot.spec

