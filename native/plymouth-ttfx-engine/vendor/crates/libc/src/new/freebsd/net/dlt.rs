//! Header: `net/dlt.h`
//!
//! https://github.com/freebsd/freebsd-src/blob/main/sys/net/dlt.h

use crate::prelude::*;

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
