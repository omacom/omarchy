//! Header: `sys/ioccom.h`
//!
//! <https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/ioccom.h>

use crate::prelude::*;

const IOCPARM_MASK: c_ulong = 0x1fff;

const IOCPARM_MAX: c_ulong = IOCPARM_MASK + 1;

// These are u32 in source but would probably be more practical as c_ulong if we ever need
// to make them public.
pub(crate) const IOC_VOID: u32 = 0x20000000;
pub(crate) const IOC_OUT: u32 = 0x40000000;
pub(crate) const IOC_IN: u32 = 0x80000000;
pub(crate) const IOC_INOUT: u32 = IOC_IN | IOC_OUT;
pub(crate) const IOC_DIRMASK: u32 = 0xe0000000;

// Only pub(crate) for the above reason.
pub(crate) const fn _IOC(inout: u32, group: c_ulong, num: c_ulong, len: c_ulong) -> c_ulong {
    debug_assert!(inout <= IOC_DIRMASK);
    debug_assert!(group <= 0xff);
    debug_assert!(num <= 0xff);
    debug_assert!(len <= IOCPARM_MAX);

    // Sanity check the cast
    assert!(size_of::<u32>() <= size_of::<c_ulong>());

    (inout as c_ulong) | ((len & IOCPARM_MASK) << 16) | (group << 8) | num
}

pub const fn _IO(g: c_ulong, n: c_ulong) -> c_ulong {
    _IOC(IOC_VOID, g, n, 0)
}

/// Build an ioctl number for an read-only ioctl.
pub const fn _IOR<T>(g: c_ulong, n: c_ulong) -> c_ulong {
    _IOC(IOC_OUT, g, n, mem::size_of::<T>() as c_ulong)
}

/// Build an ioctl number for an write-only ioctl.
pub const fn _IOW<T>(g: c_ulong, n: c_ulong) -> c_ulong {
    _IOC(IOC_IN, g, n, mem::size_of::<T>() as c_ulong)
}

/// Build an ioctl number for a read-write ioctl.
pub const fn _IOWR<T>(g: c_ulong, n: c_ulong) -> c_ulong {
    _IOC(IOC_INOUT, g, n, mem::size_of::<T>() as c_ulong)
}
