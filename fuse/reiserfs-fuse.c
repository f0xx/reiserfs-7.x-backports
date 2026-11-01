// SPDX-License-Identifier: GPL-2.0
/*
 * FUSE-style registration of the out-of-tree ReiserFS driver.
 *
 * Built on demand (`make fuse`). This is the block-device counterpart of
 * fuseblk: its own filesystem type, a subtype, and the same mount context as
 * reiserfs.ko. Disk IO stays in reiserfs.ko; this module only publishes the
 * second mount type.
 */

#include <linux/fs.h>
#include <linux/fs_context.h>
#include <linux/module.h>

int reiserfs_init_fs_context(struct fs_context *fc);
void reiserfs_kill_sb(struct super_block *sb);

static struct file_system_type reiserfs_fuse_fs_type = {
	.owner			= THIS_MODULE,
	.name			= "reiserfs-fuse",
	.init_fs_context	= reiserfs_init_fs_context,
	.kill_sb		= reiserfs_kill_sb,
	/* Same shape as the in-kernel fuseblk type, minus idmap. */
	.fs_flags		= FS_REQUIRES_DEV | FS_HAS_SUBTYPE,
};

static int __init reiserfs_fuse_init(void)
{
	return register_filesystem(&reiserfs_fuse_fs_type);
}

static void __exit reiserfs_fuse_exit(void)
{
	unregister_filesystem(&reiserfs_fuse_fs_type);
}

module_init(reiserfs_fuse_init);
module_exit(reiserfs_fuse_exit);

MODULE_DESCRIPTION("FUSE-compatible ReiserFS mount wrapper");
MODULE_AUTHOR("ReiserFS 7.x backport");
MODULE_LICENSE("GPL");
MODULE_ALIAS_FS("reiserfs-fuse");
MODULE_SOFTDEP("pre: reiserfs");
MODULE_SOFTDEP("pre: fuse");
