#TESTROOT=/tftpboot/fc5 /tftpboot/fc4 /tftpboot/chaos31
TESTROOT=/tftpboot/fc5.min

all: clean
	build .

clean:
	rm -f *.rpm *.bz2

# XXX For testing!
install:
	for rootdir in $(TESTROOT); do \
	   rm -f $$rootdir/tmp/*.rpm; \
	   cp *.noarch.rpm $$rootdir/tmp/; \
	   chroot $$rootdir rpm --ignoresize -Uvh /tmp/*.noarch.rpm; \
        done
