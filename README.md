# ReiserFS for Linux 7.x

Out-of-tree build of the ReiserFS driver against a prepared Linux 7.x tree.
The kernel sources are not modified.

`make` produces `reiserfs.ko`. `make fuse` also produces `fuse/reiserfs-fuse.ko`,
a second filesystem type (`reiserfs-fuse`) with the same mount path as
`reiserfs` and the same block-device flags as fuseblk. It is not built unless
you ask for it.

The kernel tree is `/lib/modules/$(uname -r)/build` when that kernel is 7.x.
Otherwise the first `/lib/modules/7.*/build` or `/usr/src/linux-7.*` tree is
used. Override with `KDIR=`.

```
make
make fuse
sudo insmod reiserfs.ko
sudo insmod fuse/reiserfs-fuse.ko
sudo rmmod reiserfs_fuse
sudo rmmod reiserfs
```

Load `reiserfs.ko` before `reiserfs-fuse.ko`. The wrapper's module name is
`reiserfs_fuse`; the filesystem type is `reiserfs-fuse`. Mount options are
the usual ReiserFS ones (`user_xattr`, `acl`, `data=ordered`, and so on).

A checkout path that contains a space is compiled from a copy under
`~/.cache/reiserfs-7.x-kbuild`, and the `.ko` files are copied back.
