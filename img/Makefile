# Start with fdimage.img from FreeDOS 1.0
# Increase its size from 1440 to 2880.  See:
#   http://www.freedos.org/
#   http://etherboot.sourceforge.net/doc/html/mknbi.html
# Copy in mode.com from freedos fdfullcd.iso:/freedos/setup/odin/mode.com.
# Copy in altered fdconfig.sys (started with fdboot.img:fdconfig.sys).
# Copy in autoexec.bat to redirect console to com1.
#
SRCIMG=fdboot.img
DSTIMG=freedos.img
CYL=320
SECT=36
HEAD=2

all: $(DSTIMG)

$(DSTIMG): $(SRCIMG) mode.com fdconfig.sys autoexec.bat
	echo drive x: file=\"$(SRCIMG)\" >mtoolsrc
	echo drive y: file=\"$(DSTIMG)\" >>mtoolsrc
	MTOOLSRC=mtoolsrc mformat -C -t $(CYL) -s $(SECT) -h $(HEAD) y:
	MTOOLSRC=mtoolsrc mcopy -s x: y:
	MTOOLSRC=mtoolsrc mcopy mode.com y:freedos
	MTOOLSRC=mtoolsrc mcopy -o fdconfig.sys y:
	MTOOLSRC=mtoolsrc mcopy -o autoexec.bat y:
	rm -f mtoolsrc
	./sys-freedos.pl --disk $(DSTIMG) --sectors $(SECT) --heads $(HEAD)

clean:
	rm -f mtoolsrc
veryclean: clean
	rm -f $(DSTIMG)

# Example: adding extra payload for BIOS update
#EXTRAZIP=~/Downloads/x7sla0.513.zip
#EXTRADIR=x7sla

EXTRAZIP=~/Downloads/X7SPA0.C17.zip
EXTRADIR=x7spa

extra: $(DSTIMG)
	echo drive y: file=\"$(DSTIMG)\" >mtoolsrc
	mkdir -p $(EXTRADIR)
	unzip -d $(EXTRADIR) $(EXTRAZIP)
	MTOOLSRC=mtoolsrc mcopy -s $(EXTRADIR) y:
	rm -rf $(EXTRADIR)
	rm -f mtoolsrc

# Testing
mnt: $(DSTIMG)
	sudo mount -o loop $(DSTIMG) /mnt
umnt:
	sudo umount /mnt

