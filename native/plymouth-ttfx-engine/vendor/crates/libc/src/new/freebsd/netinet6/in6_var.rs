//! Header: `netinet6/in6_var.h`
//!
//! https://github.com/freebsd/freebsd-src/blob/main/sys/netinet6/in6_var.h

use crate::prelude::*;
use crate::sys::ioccom::*;

s! {
    pub struct in6_addrlifetime {
        pub ia6t_expire: crate::time_t,
        pub ia6t_preferred: crate::time_t,
        pub ia6t_vltime: u32,
        pub ia6t_pltime: u32,
    }

    pub struct in6_ifstat {
        pub ifs6_in_receive: u64,
        pub ifs6_in_hdrerr: u64,
        pub ifs6_in_toobig: u64,
        pub ifs6_in_noroute: u64,
        pub ifs6_in_addrerr: u64,
        pub ifs6_in_protounknown: u64,
        pub ifs6_in_truncated: u64,
        pub ifs6_in_discard: u64,
        pub ifs6_in_deliver: u64,
        pub ifs6_out_forward: u64,
        pub ifs6_out_request: u64,
        pub ifs6_out_discard: u64,
        pub ifs6_out_fragok: u64,
        pub ifs6_out_fragfail: u64,
        pub ifs6_out_fragcreat: u64,
        pub ifs6_reass_reqd: u64,
        pub ifs6_reass_ok: u64,
        pub ifs6_reass_fail: u64,
        pub ifs6_in_mcast: u64,
        pub ifs6_out_mcast: u64,
    }

    pub struct icmp6_ifstat {
        pub ifs6_in_msg: u64,
        pub ifs6_in_error: u64,
        pub ifs6_in_dstunreach: u64,
        pub ifs6_in_adminprohib: u64,
        pub ifs6_in_timeexceed: u64,
        pub ifs6_in_paramprob: u64,
        pub ifs6_in_pkttoobig: u64,
        pub ifs6_in_echo: u64,
        pub ifs6_in_echoreply: u64,
        pub ifs6_in_routersolicit: u64,
        pub ifs6_in_routeradvert: u64,
        pub ifs6_in_neighborsolicit: u64,
        pub ifs6_in_neighboradvert: u64,
        pub ifs6_in_redirect: u64,
        pub ifs6_in_mldquery: u64,
        pub ifs6_in_mldreport: u64,
        pub ifs6_in_mlddone: u64,
        pub ifs6_out_msg: u64,
        pub ifs6_out_error: u64,
        pub ifs6_out_dstunreach: u64,
        pub ifs6_out_adminprohib: u64,
        pub ifs6_out_timeexceed: u64,
        pub ifs6_out_paramprob: u64,
        pub ifs6_out_pkttoobig: u64,
        pub ifs6_out_echo: u64,
        pub ifs6_out_echoreply: u64,
        pub ifs6_out_routersolicit: u64,
        pub ifs6_out_routeradvert: u64,
        pub ifs6_out_neighborsolicit: u64,
        pub ifs6_out_neighboradvert: u64,
        pub ifs6_out_redirect: u64,
        pub ifs6_out_mldquery: u64,
        pub ifs6_out_mldreport: u64,
        pub ifs6_out_mlddone: u64,
    }
}

s_no_extra_traits! {
    pub struct in6_ifreq {
        pub ifr_name: [c_char; crate::IFNAMSIZ],
        pub ifr_ifru: __c_anonymous_ifr_ifru6,
    }

    pub union __c_anonymous_ifr_ifru6 {
        pub ifru_addr: crate::sockaddr_in6,
        pub ifru_dstaddr: crate::sockaddr_in6,
        pub ifru_flags: c_int,
        pub ifru_flags6: c_int,
        pub ifru_metric: c_int,
        pub ifru_data: crate::caddr_t,
        pub ifru_lifetime: in6_addrlifetime,
        pub ifru_stat: in6_ifstat,
        pub ifru_icmp6stat: icmp6_ifstat,
        pub ifru_scope_id: [u32; 16],
    }
}

pub const IN6_IFF_ANYCAST: c_int = 0x01;
pub const IN6_IFF_TENTATIVE: c_int = 0x02;
pub const IN6_IFF_DUPLICATED: c_int = 0x04;
pub const IN6_IFF_DETACHED: c_int = 0x08;
pub const IN6_IFF_DEPRECATED: c_int = 0x10;
pub const IN6_IFF_NODAD: c_int = 0x20;
pub const IN6_IFF_AUTOCONF: c_int = 0x40;
pub const IN6_IFF_TEMPORARY: c_int = 0x80;
pub const IN6_IFF_PREFER_SOURCE: c_int = 0x0100;

pub const SIOCGIFAFLAG_IN6: c_ulong = _IOWR::<crate::in6_ifreq>('i' as c_ulong, 73);
