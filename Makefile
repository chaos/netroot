all: clean
	build .

clean:
	rm -f *.rpm *.bz2

# Testing!
TESTROOT=/tftpboot/images/default
test:
	sudo rm -rf $(TESTROOT)
	sudo mkdir -p $(TESTROOT)
	rpm2cpio nfsroot-base* | (cd $(TESTROOT) && sudo cpio -ivd)
	
