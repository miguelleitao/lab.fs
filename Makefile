
PACK_CONTENTS=dir*
DISK?=/dev/sda

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
	mksquashfs $< $@ -quiet

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
	mountpoint -q union2 || (mount -t overlay -o lowerdir=dirA,upperdir=dirB,workdir=work2 none $<)
	
unionfs3: union3 unionfs2 dirC
	mountpoint -q union3 || (mount -t overlay -o lowerdir=union2,upperdir=dirD/dirC,workdir=dirD/work3 none $<)

lvm: $(DISK)1 $(DISK)2
	@!( grep -qs ^$(DISK)1 /proc/mounts && echo "$(DISK)1 is already mounted." )
	@!( grep -qs ^$(DISK)2 /proc/mounts && echo "$(DISK)2 is already mounted." )
	pvcreate $(DISK)1
	pvcreate $(DISK)2
	vgcreate my_vg $(DISK)1 $(DISK)2
	lvcreate --size 3.2G --wipesignatures y my_vg
	mkfs -t ext2 /dev/my_vg/*0
	mkdir -p fs1
	mount /dev/my_vg/*0 fs1
	
%.pdf: %.svg
	convert -density 300 layout.svg layout.pdf

clean_lvm:
	-umount fs1 
	-rmdir fs1
	-wipefs -a /dev/my_vg/*0
	lvremove -y /dev/my_vg/* || true
	vgremove my_vg || true
	pvremove $(DISK)1 || true
	pvremove $(DISK)2 || true

clean_unionfs:
	-umount -l union3
	-umount -l union2
	-umount -l dirA
	-umount -l dirD
	rm -rf dirA.sfs dirA
	rm -rf dirB.ext2 dirB
	rm -rf dirC dirD
	rm -rf union2 union3 work2
	rm -f *.pdf

clean: clean_unionfs clean_lvm
