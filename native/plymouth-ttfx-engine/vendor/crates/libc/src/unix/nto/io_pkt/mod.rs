//! Definitions specific to QNX versions using io-pkt networking
//!
//! This module applies to:
//!
//! * `aarch64-unknown-nto-qnx700`
//! * `i686-pc-nto-qnx700`
//! * `aarch64-unknown-nto-qnx710`
//! * `x86_64-pc-nto-qnx710`

use crate::prelude::*;

s! {
    #[repr(packed)]
    pub struct in_addr {
        pub s_addr: crate::in_addr_t,
    }

    pub struct sockaddr_in {
        pub sin_len: u8,
        pub sin_family: crate::sa_family_t,
        pub sin_port: crate::in_port_t,
        pub sin_addr: crate::in_addr,
        pub sin_zero: [i8; 8],
    }

    pub struct in_pktinfo {
        pub ipi_addr: crate::in_addr,
        pub ipi_ifindex: c_uint,
    }

    #[repr(packed)]
    pub struct arphdr {
        pub ar_hrd: u16,
        pub ar_pro: u16,
        pub ar_hln: u8,
        pub ar_pln: u8,
        pub ar_op: u16,
    }

    pub struct unpcbid {
        pub unp_pid: crate::pid_t,
        pub unp_euid: crate::uid_t,
        pub unp_egid: crate::gid_t,
    }

    pub struct mmsghdr {
        pub msg_hdr: crate::msghdr,
        pub msg_len: c_uint,
    }

    pub struct bpf_stat {
        pub bs_recv: u64,
        pub bs_drop: u64,
        pub bs_capt: u64,
        bs_padding: Padding<[u64; 13]>,
    }

    pub struct sockaddr_dl {
        pub sdl_len: c_uchar,
        pub sdl_family: crate::sa_family_t,
        pub sdl_index: u16,
        pub sdl_type: c_uchar,
        pub sdl_nlen: c_uchar,
        pub sdl_alen: c_uchar,
        pub sdl_slen: c_uchar,
        pub sdl_data: [c_char; 12],
    }
}

pub const SCM_CREDS: c_int = 0x04;
pub const IFF_NOTRAILERS: c_int = 0x00000020;
pub const AF_INET6: c_int = 24;
pub const AF_BLUETOOTH: c_int = 31;
pub const pseudo_AF_KEY: c_int = 29;
pub const MSG_NOSIGNAL: c_int = 0x0800;
pub const MSG_WAITFORONE: c_int = 0x2000;
pub const IP_IPSEC_POLICY_COMPAT: c_int = 22;
pub const IP_PKTINFO: c_int = 25;
pub const IPPROTO_DIVERT: c_int = 259;
pub const IPV6_IPSEC_POLICY_COMPAT: c_int = 28;
pub const TCP_KEEPALIVE: c_int = 0x04;
pub const ARPHRD_ARCNET: u16 = 7;
pub const SO_BINDTODEVICE: c_int = 0x0800;
pub const EAI_NODATA: c_int = 7;
pub const IPTOS_ECN_NOT_ECT: u8 = 0x00;
pub const RTF_BROADCAST: u32 = 0x80000;
pub const UDP_ENCAP: c_int = 100;
pub const HW_IOSTATS: c_int = 9;
pub const HW_MACHINE_ARCH: c_int = 10;
pub const HW_ALIGNBYTES: c_int = 11;
pub const HW_CNMAGIC: c_int = 12;
pub const HW_PHYSMEM64: c_int = 13;
pub const HW_USERMEM64: c_int = 14;
pub const HW_IOSTATNAMES: c_int = 15;
pub const HW_MAXID: c_int = 15;
pub const CTL_UNSPEC: c_int = 0;
pub const CTL_QNX: c_int = 9;
pub const CTL_PROC: c_int = 10;
pub const CTL_VENDOR: c_int = 11;
pub const CTL_EMUL: c_int = 12;
pub const CTL_SECURITY: c_int = 13;
pub const CTL_MAXID: c_int = 14;
pub const AF_ARP: c_int = 28;
pub const AF_IEEE80211: c_int = 32;
pub const AF_NATM: c_int = 27;
pub const AF_NS: c_int = 6;
pub const BIOCGDLTLIST: c_int = -1072676233;
pub const BIOCGETIF: c_int = 1083196011;
pub const BIOCGSEESENT: c_int = 1074020984;
pub const BIOCGSTATS: c_int = 1082147439;
pub const BIOCSDLT: c_int = -2147204490;
pub const BIOCSETIF: c_int = -2138029460;
pub const BIOCSSEESENT: c_int = -2147204487;
pub const FIONSPACE: c_int = 1074030200;
pub const FIONWRITE: c_int = 1074030201;
pub const IFF_ACCEPTRTADV: c_int = 0x40000000;
pub const IFF_IP6FORWARDING: c_int = 0x20000000;
pub const IFF_SHIM: c_int = u32_cast_int(0x80000000);
pub const KERN_ARND: c_int = 81;
pub const KERN_IOV_MAX: c_int = 38;
pub const KERN_LOGSIGEXIT: c_int = 46;
pub const KERN_MAXID: c_int = 83;
pub const KERN_PROC_ARGS: c_int = 48;
pub const KERN_PROC_ENV: c_int = 3;
pub const KERN_PROC_GID: c_int = 7;
pub const KERN_PROC_RGID: c_int = 8;
pub const LOCAL_CONNWAIT: c_int = 0x0002;
pub const LOCAL_CREDS: c_int = 0x0001;
pub const LOCAL_PEEREID: c_int = 0x0003;
pub const MSG_NOTIFICATION: c_int = 0x0400;
pub const NET_RT_IFLIST: c_int = 4;
pub const NI_NUMERICSCOPE: c_int = 0x00000040;
pub const PF_ARP: c_int = 28;
pub const PF_NATM: c_int = 27;
pub const pseudo_AF_HDRCMPLT: c_int = 30;
pub const SIOCGIFADDR: c_int = -1064277727;
pub const SO_FIB: c_int = 0x100a;
pub const SO_TXPRIO: c_int = 0x100b;
pub const SO_SETFIB: c_int = 0x100a;
pub const SO_VLANPRIO: c_int = 0x100c;
pub const USER_ATEXIT_MAX: c_int = 21;
pub const USER_MAXID: c_int = 22;
pub const SO_OVERFLOWED: c_int = 0x1009;

extern "C" {
    pub fn sendmmsg(
        sockfd: c_int,
        msgvec: *mut crate::mmsghdr,
        vlen: c_uint,
        flags: c_uint,
    ) -> c_int;

    pub fn recvmmsg(
        sockfd: c_int,
        msgvec: *mut crate::mmsghdr,
        vlen: c_uint,
        flags: c_uint,
        timeout: *mut crate::timespec,
    ) -> c_int;
}
