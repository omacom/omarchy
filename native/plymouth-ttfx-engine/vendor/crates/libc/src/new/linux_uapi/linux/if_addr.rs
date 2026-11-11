//! Header: `uapi/linux/if_addr.h`

use crate::prelude::*;

s! {
    pub struct ifaddrmsg {
        pub ifa_family: u8,
        pub ifa_prefixlen: u8,
        pub ifa_flags: u8,
        pub ifa_scope: u8,
        pub ifa_index: u32,
    }
}

pub const IFA_UNSPEC: c_ushort = 0;
pub const IFA_ADDRESS: c_ushort = 1;
pub const IFA_LOCAL: c_ushort = 2;
pub const IFA_LABEL: c_ushort = 3;
pub const IFA_BROADCAST: c_ushort = 4;
pub const IFA_ANYCAST: c_ushort = 5;
pub const IFA_CACHEINFO: c_ushort = 6;
pub const IFA_MULTICAST: c_ushort = 7;
pub const IFA_FLAGS: c_ushort = 8;

pub const IFA_F_SECONDARY: u32 = 0x01;
pub const IFA_F_TEMPORARY: u32 = 0x01;
pub const IFA_F_NODAD: u32 = 0x02;
pub const IFA_F_OPTIMISTIC: u32 = 0x04;
pub const IFA_F_DADFAILED: u32 = 0x08;
pub const IFA_F_HOMEADDRESS: u32 = 0x10;
pub const IFA_F_DEPRECATED: u32 = 0x20;
pub const IFA_F_TENTATIVE: u32 = 0x40;
pub const IFA_F_PERMANENT: u32 = 0x80;
pub const IFA_F_MANAGETEMPADDR: u32 = 0x100;
pub const IFA_F_NOPREFIXROUTE: u32 = 0x200;
pub const IFA_F_MCAUTOJOIN: u32 = 0x400;
pub const IFA_F_STABLE_PRIVACY: u32 = 0x800;
