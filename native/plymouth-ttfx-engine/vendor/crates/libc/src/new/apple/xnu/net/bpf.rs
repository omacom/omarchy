//! Header: `net/bpf.h`
//!
//! <https://github.com/apple-oss-distributions/xnu/blob/main/bsd/net/bpf.h>

use crate::prelude::*;
use crate::sys::ioccom::*;

s! {
    pub struct bpf_insn {
        pub code: c_ushort,
        pub jt: c_uchar,
        pub jf: c_uchar,
        pub k: u32,
    }

    pub struct bpf_program {
        pub bf_len: c_uint,
        pub bf_insns: *mut bpf_insn,
    }
}

s_no_extra_traits! {
    #[repr(packed(4))]
    pub struct bpf_dltlist {
        pub bfl_len: u32,
        pub bfl_u: __c_anonymous_bfl_u,
    }

    pub union __c_anonymous_bfl_u {
        pub bflu_list: *mut u32,
        pub bflu_pad: u64,
    }
}

pub const DLT_NULL: c_uint = 0; // no link-layer encapsulation
pub const DLT_EN10MB: c_uint = 1; // Ethernet (10Mb)
pub const DLT_EN3MB: c_uint = 2; // Experimental Ethernet (3Mb)
pub const DLT_AX25: c_uint = 3; // Amateur Radio AX.25
pub const DLT_PRONET: c_uint = 4; // Proteon ProNET Token Ring
pub const DLT_CHAOS: c_uint = 5; // Chaos
pub const DLT_IEEE802: c_uint = 6; // IEEE 802 Networks
pub const DLT_ARCNET: c_uint = 7; // ARCNET
pub const DLT_SLIP: c_uint = 8; // Serial Line IP
pub const DLT_PPP: c_uint = 9; // Point-to-point Protocol
pub const DLT_FDDI: c_uint = 10; // FDDI
pub const DLT_ATM_RFC1483: c_uint = 11; // LLC/SNAP encapsulated atm
pub const DLT_RAW: c_uint = 12; // raw IP
pub const DLT_LOOP: c_uint = 108;

pub const BPF_ALIGNMENT: c_int = size_of::<i32>() as c_int;

pub const BIOCGRSIG: c_ulong = _IOR::<c_uint>('B' as c_ulong, 114);
pub const BIOCSRSIG: c_ulong = _IOW::<c_uint>('B' as c_ulong, 115);
pub const BIOCGSEESENT: c_ulong = _IOR::<c_uint>('B' as c_ulong, 118);
pub const BIOCSSEESENT: c_ulong = _IOW::<c_uint>('B' as c_ulong, 119);
pub const BIOCSDLT: c_ulong = _IOW::<c_uint>('B' as c_ulong, 120);
pub const BIOCGDLTLIST: c_ulong = _IOWR::<bpf_dltlist>('B' as c_ulong, 121);
