//! Definitions specific to QNX versions using io-sock networking
//!
//! This module applies to:
//!
//! * `aarch64-unknown-nto-qnx710`
//! * `x86_64-pc-nto-qnx710`
//! * `aarch64-unknown-qnx`
//! * `x86_64-pc-qnx`

use crate::prelude::*;

s! {
    pub struct in_addr {
        pub s_addr: crate::in_addr_t,
    }

    pub struct sockaddr_in {
        pub sin_len: u8,
        pub sin_family: crate::sa_family_t,
        pub sin_port: crate::in_port_t,
        pub sin_addr: crate::in_addr,
        pub sin_zero: [c_char; 8],
    }

    pub struct arphdr {
        pub ar_hrd: u16,
        pub ar_pro: u16,
        pub ar_hln: u8,
        pub ar_pln: u8,
        pub ar_op: u16,
    }

    pub struct mmsghdr {
        pub msg_hdr: crate::msghdr,
        pub msg_len: ssize_t,
    }

    pub struct bpf_stat {
        pub bs_recv: c_uint,
        pub bs_drop: c_uint,
    }

    pub struct sockaddr_dl {
        pub sdl_len: c_uchar,
        pub sdl_family: c_uchar,
        pub sdl_index: c_ushort,
        pub sdl_type: c_uchar,
        pub sdl_nlen: c_uchar,
        pub sdl_alen: c_uchar,
        pub sdl_slen: c_uchar,
        pub sdl_data: [c_char; 46],
    }
}

pub const SCM_CREDS: c_int = 0x03;
pub const AF_INET6: c_int = 28;
pub const AF_BLUETOOTH: c_int = 36;
pub const pseudo_AF_KEY: c_int = 27;
pub const MSG_NOSIGNAL: c_int = 0x20000;
pub const MSG_WAITFORONE: c_int = 0x00080000;
pub const IPPROTO_DIVERT: c_int = 258;
pub const RTF_BROADCAST: u32 = 0x400000;
pub const UDP_ENCAP: c_int = 1;
pub const HW_MACHINE_ARCH: c_int = 11;
pub const AF_ARP: c_int = 35;
pub const AF_IEEE80211: c_int = 37;
pub const AF_NATM: c_int = 29;
pub const BIOCGDLTLIST: c_ulong = 0xffffffffc0104279;
pub const BIOCGETIF: c_int = 0x4020426b;
pub const BIOCGSEESENT: c_int = 0x40044276;
pub const BIOCGSTATS: c_int = 0x4008426f;
pub const BIOCSDLT: c_int = u32_cast_int(0x80044278);
pub const BIOCSETIF: c_int = u32_cast_int(0x8020426c);
pub const BIOCSSEESENT: c_int = u32_cast_int(0x80044277);
pub const KERN_ARND: c_int = 37;
pub const KERN_IOV_MAX: c_int = 35;
pub const KERN_LOGSIGEXIT: c_int = 34;
pub const KERN_PROC_ARGS: c_int = 7;
pub const KERN_PROC_ENV: c_int = 35;
pub const KERN_PROC_GID: c_int = 11;
pub const KERN_PROC_RGID: c_int = 10;
pub const LOCAL_CONNWAIT: c_int = 4;
pub const LOCAL_CREDS: c_int = 2;
pub const MSG_NOTIFICATION: c_int = 0x00002000;
pub const NET_RT_IFLIST: c_int = 3;
pub const NI_NUMERICSCOPE: c_int = 0x00000020;
pub const PF_ARP: c_int = AF_ARP;
pub const PF_NATM: c_int = AF_NATM;
pub const pseudo_AF_HDRCMPLT: c_int = 31;
pub const SIOCGIFADDR: c_int = u32_cast_int(0xc0206921);
pub const SO_SETFIB: c_int = 0x1014;

extern "C" {
    pub fn sendmmsg(
        sockfd: c_int,
        msgvec: *mut crate::mmsghdr,
        vlen: size_t,
        flags: c_int,
    ) -> ssize_t;

    pub fn recvmmsg(
        sockfd: c_int,
        msgvec: *mut crate::mmsghdr,
        vlen: size_t,
        flags: c_int,
        timeout: *const crate::timespec,
    ) -> ssize_t;
}
