//! Header: `sys/sockio.h`
//!
//! <https://github.com/apple-oss-distributions/xnu/blob/main/bsd/sys/sockio.h>

use crate::prelude::*;
use crate::sys::ioccom::*;

pub const SIOCSHIWAT: c_ulong = _IOW::<c_int>('s' as c_ulong, 0);
pub const SIOCGHIWAT: c_ulong = _IOR::<c_int>('s' as c_ulong, 1);
pub const SIOCSLOWAT: c_ulong = _IOW::<c_int>('s' as c_ulong, 2);
pub const SIOCGLOWAT: c_ulong = _IOR::<c_int>('s' as c_ulong, 3);
pub const SIOCATMARK: c_ulong = _IOR::<c_int>('s' as c_ulong, 7);
pub const SIOCSPGRP: c_ulong = _IOW::<c_int>('s' as c_ulong, 8);
pub const SIOCGPGRP: c_ulong = _IOR::<c_int>('s' as c_ulong, 9);

pub const SIOCSIFADDR: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 12);
pub const SIOCSIFDSTADDR: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 14);
pub const SIOCSIFFLAGS: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 16);
pub const SIOCGIFFLAGS: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 17);
pub const SIOCSIFBRDADDR: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 19);
pub const SIOCSIFNETMASK: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 22);
pub const SIOCGIFMETRIC: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 23);
pub const SIOCSIFMETRIC: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 24);
pub const SIOCDIFADDR: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 25);
// struct ifaliasreq
pub const SIOCAIFADDR: c_ulong = _IOC(IOC_IN, 'i' as c_ulong, 26, 64);
pub const SIOCGIFDSTADDR: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 34);
pub const SIOCGIFBRDADDR: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 35);
pub const SIOCGIFCONF: c_ulong = _IOWR::<crate::ifconf>('i' as c_ulong, 36);
pub const SIOCGIFNETMASK: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 37);
pub const SIOCAUTOADDR: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 38);
pub const SIOCAUTONETMASK: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 39);
pub const SIOCARPIPLL: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 40);
pub const SIOCADDMULTI: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 49);
pub const SIOCDELMULTI: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 50);
pub const SIOCGIFMTU: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 51);
pub const SIOCSIFMTU: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 52);
pub const SIOCGIFPHYS: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 53);
pub const SIOCSIFPHYS: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 54);
pub const SIOCSIFMEDIA: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 55);
// struct ifmediareq
pub const SIOCGIFMEDIA: c_ulong = _IOC(IOC_INOUT, 'i' as c_ulong, 56, 44);
pub const SIOCSIFGENERIC: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 57);
pub const SIOCGIFGENERIC: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 58);
// struct rslvmulti_req
pub const SIOCRSLVMULTI: c_ulong = _IOC(IOC_INOUT, 'i' as c_ulong, 59, 16);
pub const SIOCSIFLLADDR: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 60);
// struct ifstat
pub const SIOCGIFSTATUS: c_ulong = _IOC(IOC_INOUT, 'i' as c_ulong, 61, 817);
// struct ifaliasreq
pub const SIOCSIFPHYADDR: c_ulong = _IOC(IOC_IN, 'i' as c_ulong, 62, 64);
pub const SIOCGIFPSRCADDR: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 63);
pub const SIOCGIFPDSTADDR: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 64);
pub const SIOCDIFPHYADDR: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 65);
pub const SIOCGIFDEVMTU: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 68);
pub const SIOCSIFALTMTU: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 69);
pub const SIOCGIFALTMTU: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 72);
pub const SIOCSIFBOND: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 70);
pub const SIOCGIFBOND: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 71);
// struct ifmediareq
pub const SIOCGIFXMEDIA: c_ulong = _IOC(IOC_INOUT, 'i' as c_ulong, 72, 44);
pub const SIOCSIFCAP: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 90);
pub const SIOCGIFCAP: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 91);
pub const SIOCSIFMANAGEMENT: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 92);
pub const SIOCIFCREATE: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 120);
pub const SIOCIFDESTROY: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 121);
pub const SIOCIFCREATE2: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 122);
// struct ifdrv
pub const SIOCSDRVSPEC: c_ulong = _IOC(IOC_IN, 'i' as c_ulong, 123, 40);
// struct ifdrv
pub const SIOCGDRVSPEC: c_ulong = _IOC(IOC_INOUT, 'i' as c_ulong, 123, 40);
pub const SIOCSIFVLAN: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 126);
pub const SIOCGIFVLAN: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 127);
pub const SIOCSETVLAN: c_ulong = SIOCSIFVLAN;
pub const SIOCGETVLAN: c_ulong = SIOCGIFVLAN;
// struct if_clonereq
pub const SIOCIFGCLONERS: c_ulong = _IOC(IOC_INOUT, 'i' as c_ulong, 129, 16);
pub const SIOCGIFASYNCMAP: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 124);
pub const SIOCSIFASYNCMAP: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 125);
pub const SIOCGIFMAC: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 130);
pub const SIOCSIFMAC: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 131);
pub const SIOCSIFKPI: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 134);
pub const SIOCGIFKPI: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 135);
pub const SIOCGIFWAKEFLAGS: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 136);
pub const SIOCGIFFUNCTIONALTYPE: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 173);
pub const SIOCSIF6LOWPAN: c_ulong = _IOW::<crate::ifreq>('i' as c_ulong, 196);
pub const SIOCGIF6LOWPAN: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 197);
pub const SIOCGIFDIRECTLINK: c_ulong = _IOWR::<crate::ifreq>('i' as c_ulong, 222);
