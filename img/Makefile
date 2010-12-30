# Start with fdimage.img from FreeDOS 1.0
# Increase its size from 1440 to 2880.  See:
#   http://www.finnix.org/Balder
#   http://etherboot.sourceforge.net/doc/html/mknbi.html
# Edit fdboot.sys to change default boot method and timeout.
# From freedos fdfullcd.iso, add some useful commands: mode
SRCIMG=fdboot.img
DSTIMG=freedos.img

all: $(DSTIMG)

bb.img: $(SRCIMG)
	dd if=$< of=$@ bs=512 count=1

$(DSTIMG): $(SRCIMG) bb.img
	echo drive x: file=\"$(SRCIMG)\" >mtoolsrc
	echo drive y: file=\"$(DSTIMG)\" >>mtoolsrc
	MTOOLSRC=mtoolsrc mformat -C -t 80 -s 36 -h 2 -B bb.img y:
	MTOOLSRC=mtoolsrc mcopy -s x: y:

clean:
	rm -f bb.img mtoolsrc
veryclean: clean
	rm -f $(DSTIMG)

mnt: $(DSTIMG)
	sudo mount -o loop $(DSTIMG) /mnt
umnt:
	sudo umount /mnt
