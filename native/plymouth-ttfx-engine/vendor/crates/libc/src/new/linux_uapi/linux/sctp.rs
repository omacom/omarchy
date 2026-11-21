use crate::prelude::*;
use crate::{
    __s32,
    __u16,
    __u32,
};

pub type sctp_assoc_t = __s32;

pub const SCTP_FUTURE_ASSOC: c_int = 0;
pub const SCTP_CURRENT_ASSOC: c_int = 1;
pub const SCTP_ALL_ASSOC: c_int = 2;

pub const SCTP_RTOINFO: c_int = 0;
pub const SCTP_ASSOCINFO: c_int = 1;
pub const SCTP_INITMSG: c_int = 2;
pub const SCTP_NODELAY: c_int = 3;
pub const SCTP_AUTOCLOSE: c_int = 4;
pub const SCTP_SET_PEER_PRIMARY_ADDR: c_int = 5;
pub const SCTP_PRIMARY_ADDR: c_int = 6;
pub const SCTP_ADAPTATION_LAYER: c_int = 7;
pub const SCTP_DISABLE_FRAGMENTS: c_int = 8;
pub const SCTP_PEER_ADDR_PARAMS: c_int = 9;
pub const SCTP_DEFAULT_SEND_PARAM: c_int = 10;
pub const SCTP_EVENTS: c_int = 11;
pub const SCTP_I_WANT_MAPPED_V4_ADDR: c_int = 12;
pub const SCTP_MAXSEG: c_int = 13;
pub const SCTP_STATUS: c_int = 14;
pub const SCTP_GET_PEER_ADDR_INFO: c_int = 15;
pub const SCTP_DELAYED_ACK_TIME: c_int = 16;
pub const SCTP_DELAYED_ACK: c_int = SCTP_DELAYED_ACK_TIME;
pub const SCTP_DELAYED_SACK: c_int = SCTP_DELAYED_ACK_TIME;
pub const SCTP_CONTEXT: c_int = 17;
pub const SCTP_FRAGMENT_INTERLEAVE: c_int = 18;
pub const SCTP_PARTIAL_DELIVERY_POINT: c_int = 19;
pub const SCTP_MAX_BURST: c_int = 20;
pub const SCTP_AUTH_CHUNK: c_int = 21;
pub const SCTP_HMAC_IDENT: c_int = 22;
pub const SCTP_AUTH_KEY: c_int = 23;
pub const SCTP_AUTH_ACTIVE_KEY: c_int = 24;
pub const SCTP_AUTH_DELETE_KEY: c_int = 25;
pub const SCTP_PEER_AUTH_CHUNKS: c_int = 26;
pub const SCTP_LOCAL_AUTH_CHUNKS: c_int = 27;
pub const SCTP_GET_ASSOC_NUMBER: c_int = 28;
pub const SCTP_GET_ASSOC_ID_LIST: c_int = 29;
pub const SCTP_AUTO_ASCONF: c_int = 30;
pub const SCTP_PEER_ADDR_THLDS: c_int = 31;
pub const SCTP_RECVRCVINFO: c_int = 32;
pub const SCTP_RECVNXTINFO: c_int = 33;
pub const SCTP_DEFAULT_SNDINFO: c_int = 34;
pub const SCTP_AUTH_DEACTIVATE_KEY: c_int = 35;
pub const SCTP_REUSE_PORT: c_int = 36;
pub const SCTP_PEER_ADDR_THLDS_V2: c_int = 37;

pub const SCTP_PR_SCTP_NONE: c_int = 0x0000;
pub const SCTP_PR_SCTP_TTL: c_int = 0x0010;
pub const SCTP_PR_SCTP_RTX: c_int = 0x0020;
pub const SCTP_PR_SCTP_PRIO: c_int = 0x0030;
/// Constants may change across releases. See the [usage guidelines](crate#usage-guidelines)
/// for details.
pub const SCTP_PR_SCTP_MAX: c_int = SCTP_PR_SCTP_PRIO;
pub const SCTP_PR_SCTP_MASK: c_int = 0x0030;

f! {
    pub unsafe fn SCTP_PR_INDEX(policy: c_int) -> c_int {
        policy >> (4 - 1)
    }

    pub unsafe fn SCTP_PR_POLICY(policy: c_int) -> c_int {
        policy & SCTP_PR_SCTP_MASK
    }

    pub unsafe fn SCTP_PR_SET_POLICY(flags: &mut c_int, policy: c_int) -> () {
        *flags &= !SCTP_PR_SCTP_MASK;
        *flags |= policy;
    }
}

safe_f! {
    pub const safe fn SCTP_PR_TTL_ENABLED(policy: c_int) -> bool {
        policy == SCTP_PR_SCTP_TTL
    }

    pub const safe fn SCTP_PR_RTX_ENABLED(policy: c_int) -> bool {
        policy == SCTP_PR_SCTP_RTX
    }

    pub const safe fn SCTP_PR_PRIO_ENABLED(policy: c_int) -> bool {
        policy == SCTP_PR_SCTP_PRIO
    }
}

pub const SCTP_ENABLE_RESET_STREAM_REQ: c_int = 0x01;
pub const SCTP_ENABLE_RESET_ASSOC_REQ: c_int = 0x02;
pub const SCTP_ENABLE_CHANGE_ASSOC_REQ: c_int = 0x04;
pub const SCTP_ENABLE_STRRESET_MASK: c_int = 0x07;

pub const SCTP_STREAM_RESET_INCOMING: c_int = 0x01;
pub const SCTP_STREAM_RESET_OUTGOING: c_int = 0x02;

pub const MSG_NOTIFICATION: c_int = 0x8000;

s! {
    pub struct sctp_initmsg {
        pub sinit_num_ostreams: __u16,
        pub sinit_max_instreams: __u16,
        pub sinit_max_attempts: __u16,
        pub sinit_max_init_timeo: __u16,
    }

    pub struct sctp_sndrcvinfo {
        pub sinfo_stream: __u16,
        pub sinfo_ssn: __u16,
        pub sinfo_flags: __u16,
        pub sinfo_ppid: __u32,
        pub sinfo_context: __u32,
        pub sinfo_timetolive: __u32,
        pub sinfo_tsn: __u32,
        pub sinfo_cumtsn: __u32,
        pub sinfo_assoc_id: crate::sctp_assoc_t,
    }

    pub struct sctp_sndinfo {
        pub snd_sid: __u16,
        pub snd_flags: __u16,
        pub snd_ppid: __u32,
        pub snd_context: __u32,
        pub snd_assoc_id: crate::sctp_assoc_t,
    }

    pub struct sctp_rcvinfo {
        pub rcv_sid: __u16,
        pub rcv_ssn: __u16,
        pub rcv_flags: __u16,
        pub rcv_ppid: __u32,
        pub rcv_tsn: __u32,
        pub rcv_cumtsn: __u32,
        pub rcv_context: __u32,
        pub rcv_assoc_id: crate::sctp_assoc_t,
    }

    pub struct sctp_nxtinfo {
        pub nxt_sid: __u16,
        pub nxt_flags: __u16,
        pub nxt_ppid: __u32,
        pub nxt_length: __u32,
        pub nxt_assoc_id: crate::sctp_assoc_t,
    }

    pub struct sctp_prinfo {
        pub pr_policy: __u16,
        pub pr_value: __u32,
    }

    pub struct sctp_authinfo {
        pub auth_keynumber: __u16,
    }
}

pub const SCTP_UNORDERED: c_int = 1 << 0;
pub const SCTP_ADDR_OVER: c_int = 1 << 1;
pub const SCTP_ABORT: c_int = 1 << 2;
pub const SCTP_SACK_IMMEDIATELY: c_int = 1 << 3;
pub const SCTP_SENDALL: c_int = 1 << 6;
pub const SCTP_PR_SCTP_ALL: c_int = 1 << 7;
pub const SCTP_NOTIFICATION: c_int = MSG_NOTIFICATION;
pub const SCTP_EOF: c_int = crate::MSG_FIN;

pub const SCTP_INIT: c_int = 0;
pub const SCTP_SNDRCV: c_int = 1;
pub const SCTP_SNDINFO: c_int = 2;
pub const SCTP_RCVINFO: c_int = 3;
pub const SCTP_NXTINFO: c_int = 4;
pub const SCTP_PRINFO: c_int = 5;
pub const SCTP_AUTHINFO: c_int = 6;
pub const SCTP_DSTADDRV4: c_int = 7;
pub const SCTP_DSTADDRV6: c_int = 8;
