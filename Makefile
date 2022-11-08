
PACK_CONTENTS=dir*

default: none

all: unionfs3 lvm layout.pdf

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

dirC: dirD/dirC

dirD/dirC: dirD
	mkdir -p $@
	mkdir -p dirD/work3
	cp -a dirC_src/* $@/

dirD: 
	mkdir -p $@
	@mountpoint $@ >/dev/null || (mount -t tmpfs dird $@)

work2:
	mkdir -p $@

union2 union3:
	mkdir -p $@

unionfs2: union2 dirA dirB work2
	@mountpoint union2 >/dev/null || (mount -t overlay -o lowerdir=dirA,upperdir=dirB,workdir=work2 none $<)
	
unionfs3: union3 unionfs2 dirC
	@mountpoint union3 >/dev/null || (mount -t overlay -o lowerdir=union2,upperdir=dirD/dirC,workdir=dirD/work3 none $<)

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
	-umount -l union3
	-umount -l union2
	-umount -l dirA
	-umount -l dirD
	rm -rf dirA.sfs dirA
	rm -rf dirB.ext2 dirB
	rm -rf dirC dirD
	rm -rf union2 union3 work2

	

