//! Header: `uapi/linux/if_packet.h`

use crate::prelude::*;

s! {
    #[deprecated(since = "0.2.70", note = "sockaddr_ll type should be used instead")]
    pub struct sockaddr_pkt {
        pub spkt_family: c_ushort,
        pub spkt_device: [c_uchar; 14],
        pub spkt_protocol: c_ushort,
    }
}

pub const PACKET_HOST: c_uchar = 0;
pub const PACKET_BROADCAST: c_uchar = 1;
pub const PACKET_MULTICAST: c_uchar = 2;
pub const PACKET_OTHERHOST: c_uchar = 3;
pub const PACKET_OUTGOING: c_uchar = 4;
pub const PACKET_LOOPBACK: c_uchar = 5;
pub const PACKET_USER: c_uchar = 6;
pub const PACKET_KERNEL: c_uchar = 7;

pub const PACKET_ADD_MEMBERSHIP: c_int = 1;
pub const PACKET_DROP_MEMBERSHIP: c_int = 2;
pub const PACKET_RECV_OUTPUT: c_int = 3;
pub const PACKET_RX_RING: c_int = 5;
pub const PACKET_STATISTICS: c_int = 6;
pub const PACKET_COPY_THRESH: c_int = 7;
pub const PACKET_AUXDATA: c_int = 8;
pub const PACKET_ORIGDEV: c_int = 9;
pub const PACKET_VERSION: c_int = 10;
pub const PACKET_HDRLEN: c_int = 11;
pub const PACKET_RESERVE: c_int = 12;
pub const PACKET_TX_RING: c_int = 13;
pub const PACKET_LOSS: c_int = 14;
pub const PACKET_VNET_HDR: c_int = 15;
pub const PACKET_TX_TIMESTAMP: c_int = 16;
pub const PACKET_TIMESTAMP: c_int = 17;
pub const PACKET_FANOUT: c_int = 18;
pub const PACKET_TX_HAS_OFF: c_int = 19;
pub const PACKET_QDISC_BYPASS: c_int = 20;
pub const PACKET_ROLLOVER_STATS: c_int = 21;
pub const PACKET_FANOUT_DATA: c_int = 22;
pub const PACKET_IGNORE_OUTGOING: c_int = 23;
pub const PACKET_VNET_HDR_SZ: c_int = 24;

pub const PACKET_FANOUT_HASH: c_uint = 0;
pub const PACKET_FANOUT_LB: c_uint = 1;
pub const PACKET_FANOUT_CPU: c_uint = 2;
pub const PACKET_FANOUT_ROLLOVER: c_uint = 3;
pub const PACKET_FANOUT_RND: c_uint = 4;
pub const PACKET_FANOUT_QM: c_uint = 5;
pub const PACKET_FANOUT_CBPF: c_uint = 6;
pub const PACKET_FANOUT_EBPF: c_uint = 7;
pub const PACKET_FANOUT_FLAG_ROLLOVER: c_uint = 0x1000;
pub const PACKET_FANOUT_FLAG_UNIQUEID: c_uint = 0x2000;
pub const PACKET_FANOUT_FLAG_IGNORE_OUTGOING: c_uint = 0x4000;
pub const PACKET_FANOUT_FLAG_DEFRAG: c_uint = 0x8000;

s! {
    pub struct tpacket_stats {
        pub tp_packets: c_uint,
        pub tp_drops: c_uint,
    }

    pub struct tpacket_stats_v3 {
        pub tp_packets: c_uint,
        pub tp_drops: c_uint,
        pub tp_freeze_q_cnt: c_uint,
    }

    #[repr(align(8))]
    pub struct tpacket_rollover_stats {
        pub tp_all: crate::__u64,
        pub tp_huge: crate::__u64,
        pub tp_failed: crate::__u64,
    }

    pub struct tpacket_auxdata {
        pub tp_status: u32,
        pub tp_len: u32,
        pub tp_snaplen: u32,
        pub tp_mac: u16,
        pub tp_net: u16,
        pub tp_vlan_tci: u16,
        pub tp_vlan_tpid: u16,
    }
}

pub const TP_STATUS_KERNEL: u32 = 0;
pub const TP_STATUS_USER: u32 = 1 << 0;
pub const TP_STATUS_COPY: u32 = 1 << 1;
pub const TP_STATUS_LOSING: u32 = 1 << 2;
pub const TP_STATUS_CSUMNOTREADY: u32 = 1 << 3;
pub const TP_STATUS_VLAN_VALID: u32 = 1 << 4;
pub const TP_STATUS_BLK_TMO: u32 = 1 << 5;
pub const TP_STATUS_VLAN_TPID_VALID: u32 = 1 << 6;
pub const TP_STATUS_CSUM_VALID: u32 = 1 << 7;

pub const TP_STATUS_AVAILABLE: u32 = 0;
pub const TP_STATUS_SEND_REQUEST: u32 = 1 << 0;
pub const TP_STATUS_SENDING: u32 = 1 << 1;
pub const TP_STATUS_WRONG_FORMAT: u32 = 1 << 2;

pub const TP_STATUS_TS_SOFTWARE: u32 = 1 << 29;
pub const TP_STATUS_TS_SYS_HARDWARE: u32 = 1 << 30;
pub const TP_STATUS_TS_RAW_HARDWARE: u32 = 1 << 31;

pub const TP_FT_REQ_FILL_RXHASH: u32 = 1;

s! {
    pub struct tpacket_hdr {
        pub tp_status: c_ulong,
        pub tp_len: c_uint,
        pub tp_snaplen: c_uint,
        pub tp_mac: c_ushort,
        pub tp_net: c_ushort,
        pub tp_sec: c_uint,
        pub tp_usec: c_uint,
    }
}

pub const TPACKET_ALIGNMENT: usize = 16;
f! {
    pub unsafe fn TPACKET_ALIGN(x: usize) -> usize {
        (x + TPACKET_ALIGNMENT - 1) & !(TPACKET_ALIGNMENT - 1)
    }
}
pub const TPACKET_HDRLEN: usize = ((size_of::<tpacket_hdr>() + TPACKET_ALIGNMENT - 1)
    & !(TPACKET_ALIGNMENT - 1))
    + size_of::<crate::sockaddr_ll>();

s! {
    pub struct tpacket2_hdr {
        pub tp_status: u32,
        pub tp_len: u32,
        pub tp_snaplen: u32,
        pub tp_mac: u16,
        pub tp_net: u16,
        pub tp_sec: u32,
        pub tp_nsec: u32,
        pub tp_vlan_tci: u16,
        pub tp_vlan_tpid: u16,
        pub tp_padding: [u8; 4],
    }

    pub struct tpacket_hdr_variant1 {
        pub tp_rxhash: u32,
        pub tp_vlan_tci: u32,
        pub tp_vlan_tpid: u16,
        pub tp_padding: u16,
    }

    pub struct tpacket3_hdr {
        pub tp_next_offset: u32,
        pub tp_sec: u32,
        pub tp_nsec: u32,
        pub tp_snaplen: u32,
        pub tp_len: u32,
        pub tp_status: u32,
        pub tp_mac: u16,
        pub tp_net: u16,
        pub hv1: tpacket_hdr_variant1,
        pub tp_padding: [u8; 8],
    }

    pub struct tpacket_bd_ts {
        pub ts_sec: c_uint,
        pub ts_usec: c_uint,
    }

    #[repr(align(8))]
    pub struct tpacket_hdr_v1 {
        pub block_status: u32,
        pub num_pkts: u32,
        pub offset_to_first_pkt: u32,
        pub blk_len: u32,
        pub seq_num: crate::__u64,
        pub ts_first_pkt: tpacket_bd_ts,
        pub ts_last_pkt: tpacket_bd_ts,
    }
}

s_no_extra_traits! {
    pub union tpacket_bd_header_u {
        pub bh1: tpacket_hdr_v1,
    }

    pub struct tpacket_block_desc {
        pub version: u32,
        pub offset_to_priv: u32,
        pub hdr: tpacket_bd_header_u,
    }
}

pub const TPACKET2_HDRLEN: usize = ((size_of::<tpacket2_hdr>() + TPACKET_ALIGNMENT - 1)
    & !(TPACKET_ALIGNMENT - 1))
    + size_of::<crate::sockaddr_ll>();
pub const TPACKET3_HDRLEN: usize = ((size_of::<tpacket3_hdr>() + TPACKET_ALIGNMENT - 1)
    & !(TPACKET_ALIGNMENT - 1))
    + size_of::<crate::sockaddr_ll>();

e! {
    #[repr(u32)]
    pub enum tpacket_versions {
        TPACKET_V1,
        TPACKET_V2,
        TPACKET_V3,
    }
}

s! {
    pub struct tpacket_req {
        pub tp_block_size: c_uint,
        pub tp_block_nr: c_uint,
        pub tp_frame_size: c_uint,
        pub tp_frame_nr: c_uint,
    }

    pub struct tpacket_req3 {
        pub tp_block_size: c_uint,
        pub tp_block_nr: c_uint,
        pub tp_frame_size: c_uint,
        pub tp_frame_nr: c_uint,
        pub tp_retire_blk_tov: c_uint,
        pub tp_sizeof_priv: c_uint,
        pub tp_feature_req_word: c_uint,
    }
}

s_no_extra_traits! {
    pub union tpacket_req_u {
        pub req: tpacket_req,
        pub req3: tpacket_req3,
    }
}

s! {
    pub struct packet_mreq {
        pub mr_ifindex: c_int,
        pub mr_type: c_ushort,
        pub mr_alen: c_ushort,
        pub mr_address: [c_uchar; 8],
    }

    pub struct fanout_args {
        #[cfg(target_endian = "little")]
        pub id: u16,
        pub type_flags: u16,
        #[cfg(target_endian = "big")]
        pub id: u16,
        pub max_num_members: u32,
    }
}

pub const PACKET_MR_MULTICAST: c_int = 0;
pub const PACKET_MR_PROMISC: c_int = 1;
pub const PACKET_MR_ALLMULTI: c_int = 2;
