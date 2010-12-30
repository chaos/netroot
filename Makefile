TESTROOT=/tftpboot/images/default

all: clean
	build .

clean:
	rm -f *.rpm *.bz2

# XXX For testing!
testd:
	sudo rm -rf $(TESTROOT)
	sudo mkdir -p $(TESTROOT)
	rpm2cpio nfsroot-base* | (cd $(TESTROOT) && sudo cpio -ivd)
	
