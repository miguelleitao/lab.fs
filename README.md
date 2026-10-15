# lab.fs
### Layered Filesystem and LVM Demos

## Usage:

### SquashFS filesystem
```
make dirA.sfs
file dirA.sfs
make dirA
ls dirA
echo 2222 >> dirA/a1.txt
```

### TempFS filesystem
```
make dirD
ls dirD
```


### Layered filesystem 2
```
make unionfs2
ls union2
echo 2222 >>union2/a1.txt
rm union2/a2,txt
ls -l union2
cat  union2/a1.txt
ls -l dirA
ls -l dirB
```

### Layered filesystem 3
```
make unionfs3
ls union3
echo 2222 >>union3/a1.txt
rm union3/a1.txt
ls -l union3
cat  union3/a1.txt
ls -l dirA
ls -l dirB
```

#### Cleanup
```
make clean_unionfs
```

### LVM
```
make lvm
```

#### Cleanup
```
make clean_lvm
```

