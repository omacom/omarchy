//! Header: `sys/ttycom.h`
//!
//! <https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/ttycom.h>

use crate::prelude::*;
use crate::sys::ioccom::*;

/* FIXME(1.0): a number of ioctl numbers are `c_int` or `c_uint` and should be changed to
 * `c_ulong` to match the others. */

pub const TIOCMODG: c_ulong = _IOR::<c_int>('t' as c_ulong, 3);
pub const TIOCMODS: c_ulong = _IOW::<c_int>('t' as c_ulong, 4);

pub const TIOCM_LE: c_int = 0o0001;
pub const TIOCM_DTR: c_int = 0o0002;
pub const TIOCM_RTS: c_int = 0o0004;
pub const TIOCM_ST: c_int = 0o0010;
pub const TIOCM_SR: c_int = 0o0020;
pub const TIOCM_CTS: c_int = 0o0040;
pub const TIOCM_CAR: c_int = 0o0100;
pub const TIOCM_CD: c_int = TIOCM_CAR;
pub const TIOCM_RNG: c_int = 0o0200;
pub const TIOCM_RI: c_int = TIOCM_RNG;
pub const TIOCM_DSR: c_int = 0o0400;

pub const TIOCEXCL: c_int = ulong_cast_int(_IO('t' as c_ulong, 13));
pub const TIOCNXCL: c_int = ulong_cast_int(_IO('t' as c_ulong, 14));

pub const TIOCFLUSH: c_ulong = _IOW::<c_int>('t' as c_ulong, 16);

pub const TIOCGETA: c_ulong = _IOR::<crate::termios>('t' as c_ulong, 19);
pub const TIOCSETA: c_ulong = _IOW::<crate::termios>('t' as c_ulong, 20);
pub const TIOCSETAW: c_ulong = _IOW::<crate::termios>('t' as c_ulong, 21);
pub const TIOCSETAF: c_ulong = _IOW::<crate::termios>('t' as c_ulong, 22);

pub const TIOCGETD: c_ulong = _IOR::<c_int>('t' as c_ulong, 26);
pub const TIOCSETD: c_ulong = _IOW::<c_int>('t' as c_ulong, 27);

pub const TIOCIXON: c_int = ulong_cast_int(_IO('t' as c_ulong, 129));
pub const TIOCIXOFF: c_int = ulong_cast_int(_IO('t' as c_ulong, 128));

pub const TIOCSBRK: c_int = ulong_cast_int(_IO('t' as c_ulong, 123));
pub const TIOCCBRK: c_int = ulong_cast_int(_IO('t' as c_ulong, 122));
pub const TIOCSDTR: c_int = ulong_cast_int(_IO('t' as c_ulong, 121));
pub const TIOCCDTR: c_int = ulong_cast_int(_IO('t' as c_ulong, 120));
pub const TIOCGPGRP: c_ulong = _IOR::<c_int>('t' as c_ulong, 119);
pub const TIOCSPGRP: c_ulong = _IOW::<c_int>('t' as c_ulong, 118);

pub const TIOCOUTQ: c_ulong = _IOR::<c_int>('t' as c_ulong, 115);
pub const TIOCSTI: c_ulong = _IOW::<c_char>('t' as c_ulong, 114);
pub const TIOCNOTTY: c_ulong = _IO('t' as c_ulong, 113);
pub const TIOCPKT: c_ulong = _IOW::<c_int>('t' as c_ulong, 112);

pub const TIOCPKT_DATA: c_int = 0x00;
pub const TIOCPKT_FLUSHREAD: c_int = 0x01;
pub const TIOCPKT_FLUSHWRITE: c_int = 0x02;
pub const TIOCPKT_STOP: c_int = 0x04;
pub const TIOCPKT_START: c_int = 0x08;
pub const TIOCPKT_NOSTOP: c_int = 0x10;
pub const TIOCPKT_DOSTOP: c_int = 0x20;
pub const TIOCPKT_IOCTL: c_int = 0x40;

pub const TIOCSTOP: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 111));
pub const TIOCSTART: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 110));
pub const TIOCMSET: c_ulong = _IOW::<c_int>('t' as c_ulong, 109);
pub const TIOCMBIS: c_ulong = _IOW::<c_int>('t' as c_ulong, 108);
pub const TIOCMBIC: c_ulong = _IOW::<c_int>('t' as c_ulong, 107);
pub const TIOCMGET: c_ulong = _IOR::<c_int>('t' as c_ulong, 106);

#[deprecated(since = "0.2.178", note = "Removed in MacOSX 12.0.1")]
pub const TIOCREMOTE: c_ulong = 0x80047469;

pub const TIOCGWINSZ: c_ulong = _IOR::<crate::winsize>('t' as c_ulong, 104);
pub const TIOCSWINSZ: c_ulong = _IOW::<crate::winsize>('t' as c_ulong, 103);
pub const TIOCUCNTL: c_ulong = _IOW::<c_int>('t' as c_ulong, 102);
pub const TIOCSTAT: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 101));

pub const TIOCSCONS: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 99));
pub const TIOCCONS: c_ulong = _IOW::<c_int>('t' as c_ulong, 98);
pub const TIOCSCTTY: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 97));
pub const TIOCEXT: c_ulong = _IOW::<c_int>('t' as c_ulong, 96);
pub const TIOCSIG: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 95));
pub const TIOCDRAIN: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 94));
pub const TIOCMSDTRWAIT: c_ulong = _IOW::<c_int>('t' as c_ulong, 91);
pub const TIOCMGDTRWAIT: c_ulong = _IOR::<c_int>('t' as c_ulong, 90);
pub const TIOCTIMESTAMP: c_ulong = _IOR::<crate::timeval>('t' as c_ulong, 89);
pub const TIOCDCDTIMESTAMP: c_ulong = _IOR::<crate::timeval>('t' as c_ulong, 88);
pub const TIOCSDRAINWAIT: c_ulong = _IOW::<c_int>('t' as c_ulong, 87);
pub const TIOCGDRAINWAIT: c_ulong = _IOR::<c_int>('t' as c_ulong, 86);
pub const TIOCDSIMICROCODE: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 85));
pub const TIOCPTYGRANT: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 84));
pub const TIOCPTYGNAME: c_uint = ulong_cast_uint(_IOC(IOC_OUT, 't' as c_ulong, 83, 128));
pub const TIOCPTYUNLK: c_uint = ulong_cast_uint(_IO('t' as c_ulong, 82));
