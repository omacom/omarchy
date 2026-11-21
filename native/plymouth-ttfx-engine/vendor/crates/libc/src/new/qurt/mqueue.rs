//! Header: `mqueue.h`
//!
//! QuRT POSIX message queue API. Also provides select/pselect and fd_set
//! operations since these are declared in QuRT's mqueue.h.

use super::*;
use crate::prelude::*;

// Message queue priority constants
pub const MQ_PRIO_DEFAULT: c_int = 0;

// Bits per byte
pub const NBBY: c_uint = 8;

s! {
    pub struct mq_attr {
        pub mq_flags: c_long,
        pub mq_maxmsg: c_long,
        pub mq_msgsize: c_long,
        pub mq_curmsgs: c_long,
    }
}

extern "C" {
    // Message queue operations
    pub fn mq_open(name: *const c_char, oflag: c_int, ...) -> mqd_t;
    pub fn mq_close(mq_desc: mqd_t) -> c_int;
    pub fn mq_unlink(name: *const c_char) -> c_int;
    pub fn mq_send(
        mqdes: mqd_t,
        msg_ptr: *const c_char,
        msg_len: size_t,
        msg_prio: c_uint,
    ) -> c_int;
    pub fn mq_timedsend(
        mqdes: mqd_t,
        msg_ptr: *const c_char,
        msg_len: size_t,
        msg_prio: c_uint,
        abs_timeout: *const timespec,
    ) -> c_int;
    pub fn mq_receive(
        mqdes: mqd_t,
        msg_ptr: *mut c_char,
        msg_len: size_t,
        msg_prio: *mut c_uint,
    ) -> ssize_t;
    pub fn mq_timedreceive(
        mqdes: mqd_t,
        msg_ptr: *mut c_char,
        msg_len: size_t,
        msg_prio: *mut c_uint,
        abs_timeout: *const timespec,
    ) -> ssize_t;
    pub fn mq_getattr(mqdes: mqd_t, mqstat: *mut mq_attr) -> c_int;
    pub fn mq_setattr(mqdes: mqd_t, mqstat: *const mq_attr, omqstat: *mut mq_attr) -> c_int;

    // select/pselect (declared in QuRT mqueue.h)
    pub fn select(
        nfds: c_int,
        readfds: *mut fd_set,
        writefds: *mut fd_set,
        errorfds: *mut fd_set,
        timeout: *mut timeval,
    ) -> c_int;
    pub fn pselect(
        nfds: c_int,
        readfds: *mut fd_set,
        writefds: *mut fd_set,
        errorfds: *mut fd_set,
        timeout: *const timespec,
        sigmask: *const sigset_t,
    ) -> c_int;
}
