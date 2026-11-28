//! Header: `sys/ioccom.h`
//!
//! https://github.com/freebsd/freebsd-src/blob/main/sys/sys/ioccom.h

use crate::prelude::*;

const IOCPARM_SHIFT: c_ulong = 13;
const IOCPARM_MASK: c_ulong = (1 << IOCPARM_SHIFT) - 1;

const IOCPARM_MAX: c_ulong = 1 << IOCPARM_SHIFT;

pub(crate) const IOC_VOID: c_ulong = 0x20000000;
pub(crate) const IOC_OUT: c_ulong = 0x40000000;
pub(crate) const IOC_IN: c_ulong = 0x80000000;
pub(crate) const IOC_INOUT: c_ulong = IOC_IN | IOC_OUT;
pub(crate) const IOC_DIRMASK: c_ulong = IOC_VOID | IOC_OUT | IOC_IN;

pub(crate) const fn _IOC(inout: c_ulong, group: c_ulong, num: c_ulong, len: c_ulong) -> c_ulong {
    debug_assert!(inout <= IOC_DIRMASK);
    debug_assert!(group <= 0xff);
    debug_assert!(num <= 0xff);
    debug_assert!(len <= IOCPARM_MAX);

    inout | ((len & IOCPARM_MASK) << 16) | (group << 8) | num
}

pub const fn _IO(g: c_ulong, n: c_ulong) -> c_ulong {
    _IOC(IOC_VOID, g, n, 0)
}

/// Build an ioctl number for an ioctl that passes an `int` by value.
pub const fn _IOWINT(g: c_ulong, n: c_ulong) -> c_ulong {
    _IOC(IOC_VOID, g, n, mem::size_of::<c_int>() as c_ulong)
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
