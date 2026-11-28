//! Header: `uapi/linux/mount.h`

use crate::prelude::*;

pub const MS_RMT_MASK: c_ulong = crate::MS_RDONLY
    | crate::MS_SYNCHRONOUS
    | crate::MS_MANDLOCK
    | crate::MS_I_VERSION
    | crate::MS_LAZYTIME;

pub const OPEN_TREE_CLONE: c_uint = 0x01;
pub const OPEN_TREE_NAMESPACE: c_uint = 0x02;
pub const OPEN_TREE_CLOEXEC: c_uint = crate::O_CLOEXEC as c_uint;

pub const MOVE_MOUNT_F_SYMLINKS: c_uint = 0x00000001;
pub const MOVE_MOUNT_F_AUTOMOUNTS: c_uint = 0x00000002;
pub const MOVE_MOUNT_F_EMPTY_PATH: c_uint = 0x00000004;
pub const MOVE_MOUNT_T_SYMLINKS: c_uint = 0x00000010;
pub const MOVE_MOUNT_T_AUTOMOUNTS: c_uint = 0x00000020;
pub const MOVE_MOUNT_T_EMPTY_PATH: c_uint = 0x00000040;
pub const MOVE_MOUNT_SET_GROUP: c_uint = 0x00000100;
pub const MOVE_MOUNT_BENEATH: c_uint = 0x00000200;

pub const FSOPEN_CLOEXEC: c_uint = 0x00000001;

pub const FSPICK_CLOEXEC: c_uint = 0x00000001;
pub const FSPICK_SYMLINK_NOFOLLOW: c_uint = 0x00000002;
pub const FSPICK_NO_AUTOMOUNT: c_uint = 0x00000004;
pub const FSPICK_EMPTY_PATH: c_uint = 0x00000008;

c_enum! {
    pub enum fsconfig_command {
        pub FSCONFIG_SET_FLAG,
        pub FSCONFIG_SET_STRING,
        pub FSCONFIG_SET_BINARY,
        pub FSCONFIG_SET_PATH,
        pub FSCONFIG_SET_PATH_EMPTY,
        pub FSCONFIG_SET_FD,
        pub FSCONFIG_CMD_CREATE,
        pub FSCONFIG_CMD_RECONFIGURE,
        pub FSCONFIG_CMD_CREATE_EXCL,
    }
}

pub const FSMOUNT_CLOEXEC: c_uint = 0x00000001;

pub const MOUNT_ATTR_RDONLY: u64 = 0x00000001;
pub const MOUNT_ATTR_NOSUID: u64 = 0x00000002;
pub const MOUNT_ATTR_NODEV: u64 = 0x00000004;
pub const MOUNT_ATTR_NOEXEC: u64 = 0x00000008;
pub const MOUNT_ATTR__ATIME: u64 = 0x00000070;
pub const MOUNT_ATTR_RELATIME: u64 = 0x00000000;
pub const MOUNT_ATTR_NOATIME: u64 = 0x00000010;
pub const MOUNT_ATTR_STRICTATIME: u64 = 0x00000020;
pub const MOUNT_ATTR_NODIRATIME: u64 = 0x00000080;
pub const MOUNT_ATTR_IDMAP: u64 = 0x00100000;
pub const MOUNT_ATTR_NOSYMFOLLOW: u64 = 0x00200000;

s! {
    pub struct mount_attr {
        pub attr_set: crate::__u64,
        pub attr_clr: crate::__u64,
        pub propagation: crate::__u64,
        pub userns_fd: crate::__u64,
    }
}

pub const MOUNT_ATTR_SIZE_VER0: c_int = 32;
