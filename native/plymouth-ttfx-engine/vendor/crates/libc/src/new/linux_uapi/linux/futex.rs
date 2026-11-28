//! Header: `linux/futex.h`

use crate::prelude::*;

pub const FUTEX_WAIT: c_int = 0;
pub const FUTEX_WAKE: c_int = 1;
pub const FUTEX_FD: c_int = 2;
pub const FUTEX_REQUEUE: c_int = 3;
pub const FUTEX_CMP_REQUEUE: c_int = 4;
pub const FUTEX_WAKE_OP: c_int = 5;
pub const FUTEX_LOCK_PI: c_int = 6;
pub const FUTEX_UNLOCK_PI: c_int = 7;
pub const FUTEX_TRYLOCK_PI: c_int = 8;
pub const FUTEX_WAIT_BITSET: c_int = 9;
pub const FUTEX_WAKE_BITSET: c_int = 10;
pub const FUTEX_WAIT_REQUEUE_PI: c_int = 11;
pub const FUTEX_CMP_REQUEUE_PI: c_int = 12;
pub const FUTEX_LOCK_PI2: c_int = 13;

pub const FUTEX_PRIVATE_FLAG: c_int = 128;
pub const FUTEX_CLOCK_REALTIME: c_int = 256;

pub const FUTEX_CMD_MASK: c_int = !(FUTEX_PRIVATE_FLAG | FUTEX_CLOCK_REALTIME);

pub const FUTEX2_SIZE_U8: c_int = 0x00;
pub const FUTEX2_SIZE_U16: c_int = 0x01;
pub const FUTEX2_SIZE_U32: c_int = 0x02;
pub const FUTEX2_SIZE_U64: c_int = 0x03;
pub const FUTEX2_NUMA: c_int = 0x04;
pub const FUTEX2_PRIVATE: c_int = FUTEX_PRIVATE_FLAG;
pub const FUTEX2_SIZE_MASK: c_int = 0x03;

#[deprecated(
    since = "0.2.187",
    note = "UAPI headers indicate this should not be used"
)]
pub const FUTEX_32: c_int = FUTEX2_SIZE_U32;

pub const FUTEX_WAITV_MAX: c_int = 128;

s! {
    pub struct futex_waitv {
        pub val: crate::__u64,
        pub uaddr: crate::__u64,
        pub flags: crate::__u32,
        __reserved: Padding<crate::__u32>,
    }
}

pub const FUTEX_WAITERS: u32 = 0x80000000;
pub const FUTEX_OWNER_DIED: u32 = 0x40000000;
pub const FUTEX_TID_MASK: u32 = 0x3fffffff;

pub const FUTEX_BITSET_MATCH_ANY: c_int = u32_cast_int(0xffffffff);

pub const FUTEX_OP_SET: c_int = 0;
pub const FUTEX_OP_ADD: c_int = 1;
pub const FUTEX_OP_OR: c_int = 2;
pub const FUTEX_OP_ANDN: c_int = 3;
pub const FUTEX_OP_XOR: c_int = 4;

pub const FUTEX_OP_OPARG_SHIFT: c_int = 8;

pub const FUTEX_OP_CMP_EQ: c_int = 0;
pub const FUTEX_OP_CMP_NE: c_int = 1;
pub const FUTEX_OP_CMP_LT: c_int = 2;
pub const FUTEX_OP_CMP_LE: c_int = 3;
pub const FUTEX_OP_CMP_GT: c_int = 4;
pub const FUTEX_OP_CMP_GE: c_int = 5;

pub fn FUTEX_OP(op: c_int, oparg: c_int, cmp: c_int, cmparg: c_int) -> c_int {
    ((op & 0xf) << 28) | ((cmp & 0xf) << 24) | ((oparg & 0xfff) << 12) | (cmparg & 0xfff)
}
