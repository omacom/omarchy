//! * Header: `uapi/linux/types.h`
//! * Header: `uapi/asm-generic/int-ll64.h`

use crate::prelude::*;

/* Definitions from `asm/types.h` -> `asm-generic/types.h` -> `asm-generic/int-ll64.h` */

pub type __u8 = c_uchar;

pub type __u16 = c_ushort;
pub type __s16 = c_short;

pub type __u32 = c_uint;
pub type __s32 = c_int;

pub type __s64 = c_longlong;
pub type __u64 = c_ulonglong;
