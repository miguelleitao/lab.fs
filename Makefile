
PACK_CONTENTS=dir*

default: none

all: unionfs lvm layout.pdf

pack.tar: ${PACK_CONTENTS}
	tar cvf $@ $^

pack.tgz: ${PACK_CONTENTS}
	tar cvzf $@ $^

pack.tar.gz: pack.tar
	gzip $<

pack.cpio: 
	find . -name "*.txt" |cpio -o >$@

dirA.sfs: dirA_src
	mksquashfs $< $@

dirA: dirA.sfs 
	mkdir -p $@
	@mountpoint $@ >/dev/null || (mount $< $@ && echo mount $< $@)

dirB:
	mkdir -p $@
	cp -a dirB_src/* $@/

dirC:
	mkdir -p $@

dirD: 
	mkdir -p $@
	mount -t tmpfs dird $@

union:
	mkdir union

unionfs: union dirA dirB dirC
	@umount -q dirC || true
	mount -t overlay -o lowerdir=dirA,upperdir=dirB,workdir=dirC none $<
	cp -f dirC_src/* union/
	
	
lvm:
	pvcreate /dev/sda1
	pvcreate /dev/sda2
	vgcreate my_vg /dev/sda1 /dev/sda2
	lvcreate --size 320M my_vg
	mkfs -t ext2 /dev/my_vg/*0
	mkdir -p fs1
	mount /dev/my_vg/*0 fs1
	
%.pdf: %.svg
	convert -density 300 layout.svg layout.pdf

clean_lvm:
	-umount fs1 
	-rmdir fs1
	-lvremove /dev/my_vg/* 
	-vgremove my_vg
	pvremove /dev/sda1
	pvremove /dev/sda2

clean:
	umount -l union || true
	umount -l dirA  || true
	umount -l dirB  || true
	umount -l dirC  || true
	rm -rf dirA.sfs dirA
	rm -rf dirB.ext2 dirB
	rm -rf dirC dirD
	rm -rf union
	rm -f pack.*

	

