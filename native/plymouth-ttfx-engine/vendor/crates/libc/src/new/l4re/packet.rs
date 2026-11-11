//! Header: `netpacket/packet.h`

use crate::prelude::*;

pub const PACKET_HOST: c_uchar = 0;
pub const PACKET_BROADCAST: c_uchar = 1;
pub const PACKET_MULTICAST: c_uchar = 2;
pub const PACKET_OTHERHOST: c_uchar = 3;
pub const PACKET_OUTGOING: c_uchar = 4;
pub const PACKET_LOOPBACK: c_uchar = 5;

pub const PACKET_ADD_MEMBERSHIP: c_int = 1;
pub const PACKET_DROP_MEMBERSHIP: c_int = 2;
pub const PACKET_RECV_OUTPUT: c_int = 3;
pub const PACKET_RX_RING: c_int = 5;
pub const PACKET_STATISTICS: c_int = 6;

s! {
    pub struct packet_mreq {
        pub mr_ifindex: c_int,
        pub mr_type: c_ushort,
        pub mr_alen: c_ushort,
        pub mr_address: [c_uchar; 8],
    }
}

pub const PACKET_MR_MULTICAST: c_int = 0;
pub const PACKET_MR_PROMISC: c_int = 1;
pub const PACKET_MR_ALLMULTI: c_int = 2;
