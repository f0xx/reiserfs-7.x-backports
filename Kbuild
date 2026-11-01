# SPDX-License-Identifier: GPL-2.0
# Out-of-tree ReiserFS module. Feature switches are passed by the top-level Makefile
# (REISERFS_PROC, REISERFS_ACL, REISERFS_SEC) from the target kernel's auto.conf.

ccflags-y += -I$(src)/include
ccflags-y += -DCONFIG_REISERFS_FS_XATTR

reiserfs-y := \
	src/bitmap.o \
	src/do_balan.o \
	src/namei.o \
	src/inode.o \
	src/file.o \
	src/dir.o \
	src/fix_node.o \
	src/super.o \
	src/prints.o \
	src/objectid.o \
	src/lbalance.o \
	src/ibalance.o \
	src/stree.o \
	src/hashes.o \
	src/tail_conversion.o \
	src/journal.o \
	src/resize.o \
	src/item_ops.o \
	src/ioctl.o \
	src/xattr.o \
	src/lock.o \
	src/xattr_user.o \
	src/xattr_trusted.o

ifeq ($(REISERFS_PROC),y)
ccflags-y += -DCONFIG_REISERFS_PROC_INFO
reiserfs-y += src/procfs.o
endif

ifeq ($(REISERFS_ACL),y)
ccflags-y += -DCONFIG_REISERFS_FS_POSIX_ACL
reiserfs-y += src/xattr_acl.o
endif

ifeq ($(REISERFS_SEC),y)
ccflags-y += -DCONFIG_REISERFS_FS_SECURITY
reiserfs-y += src/xattr_security.o
endif

obj-m += reiserfs.o
