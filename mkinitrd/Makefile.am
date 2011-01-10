rootsbindir = /sbin

rootsbin_SCRIPTS = mkinitrd_nfsroot nfsroot-kernel-pkg mklivecd
man8_MANS = mkinitrd_nfsroot.8 mklivecd.8

pkglibdir = @X_DATADIR@/@PACKAGE@

pkglib_DATA = initrd-init profile nfsrootfun.sh

EXTRA_DIST = \
	profile \
	initrd-init \
	nfsrootfun.sh \
	mkinitrd_nfsroot \
	mkinitrd_nfsroot.8 \
	nfsroot-kernel-pkg \
	mklivecd
