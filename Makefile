# SPDX-License-Identifier: GPL-2.0
# Standalone ReiserFS modules for Linux 7.x. Does not modify the kernel tree.
#
#   make            -> reiserfs.ko
#   make fuse       -> reiserfs-fuse.ko (needs reiserfs.ko's Module.symvers)
#   make KDIR=/path/to/linux-7.x

empty :=
space := $(empty) $(empty)
ROOT  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

ifeq ($(KDIR),)
  _uname := $(shell uname -r)
  ifneq ($(filter 7.%,$(_uname)),)
    KDIR := /lib/modules/$(_uname)/build
  endif
endif

ifeq ($(KDIR),)
  KDIR := $(firstword $(wildcard /lib/modules/7.*/build /usr/src/linux-7.*))
endif

ifeq ($(wildcard $(KDIR)/Makefile),)
  $(error Linux 7.x kernel build tree not found. Pass KDIR=/path/to/prepared/kernel)
endif

_kver := $(shell sed -n 's/^VERSION *= *//p' "$(KDIR)/Makefile")
ifneq ($(_kver),7)
  $(error $(KDIR) is Linux $(_kver).x; this package builds only against Linux 7.x)
endif

AUTOCONF := $(KDIR)/include/config/auto.conf
ifeq ($(wildcard $(AUTOCONF)),)
  $(error $(KDIR) is not prepared (missing include/config/auto.conf))
endif

include $(AUTOCONF)

ifeq ($(CONFIG_PROC_FS),y)
  REISERFS_PROC := y
endif
ifeq ($(CONFIG_FS_POSIX_ACL),y)
  REISERFS_ACL := y
endif
ifeq ($(CONFIG_SECURITY),y)
  REISERFS_SEC := y
endif

# kbuild splits M= on spaces and resolves symlinks, so a path with a space
# is built from a spaceless copy. Products are copied back.
ifeq ($(findstring $(space),$(ROOT)),)
  MDIR := $(ROOT)
  SYNC :=
else
  MDIR := $(HOME)/.cache/reiserfs-7.x-kbuild
  SYNC := yes
endif

KBUILD := $(MAKE) -C "$(KDIR)" M="$(MDIR)" \
	REISERFS_PROC="$(REISERFS_PROC)" \
	REISERFS_ACL="$(REISERFS_ACL)" \
	REISERFS_SEC="$(REISERFS_SEC)"

.PHONY: all modules fuse clean prepare

all: modules

prepare:
ifeq ($(SYNC),yes)
	@if [ -L "$(MDIR)" ]; then rm -f "$(MDIR)"; fi
	@mkdir -p "$(MDIR)"
	rsync -a --delete \
		--exclude '.git/' \
		--exclude '*.o' --exclude '*.ko' --exclude '*.mod' \
		--exclude '*.mod.c' --exclude '*.mod.o' --exclude '.*.cmd' \
		--exclude 'modules.order' --exclude 'Module.symvers' \
		"$(ROOT)/" "$(MDIR)/"
endif

modules: prepare
	+$(KBUILD) modules
ifeq ($(SYNC),yes)
	cp -a "$(MDIR)/reiserfs.ko" "$(MDIR)/modules.order" "$(MDIR)/Module.symvers" "$(ROOT)/"
endif

fuse: modules
	+$(MAKE) -C "$(KDIR)" M="$(MDIR)/fuse" \
		KBUILD_EXTRA_SYMBOLS="$(MDIR)/Module.symvers" modules
ifeq ($(SYNC),yes)
	cp -a "$(MDIR)/fuse/reiserfs-fuse.ko" "$(ROOT)/fuse/"
endif

clean: prepare
	+$(KBUILD) clean
	+$(MAKE) -C "$(KDIR)" M="$(MDIR)/fuse" clean
ifeq ($(SYNC),yes)
	rm -f "$(ROOT)/reiserfs.ko" "$(ROOT)/modules.order" "$(ROOT)/Module.symvers" \
		"$(ROOT)/fuse/reiserfs-fuse.ko"
endif

