//! Header: `sys/sched.h`
//!
//! QuRT scheduling parameters and functions.

use crate::prelude::*;

// Scheduling policies (from QuRT sys/sched.h)
pub const SCHED_FIFO: c_int = 0;
pub const SCHED_RR: c_int = 1;
pub const SCHED_SPORADIC: c_int = 2;
pub const SCHED_OTHER: c_int = 3;

s! {
    pub struct sched_param {
        pub unimplemented: *mut c_void,
        pub sched_priority: c_int,
    }
}

extern "C" {
    // Note: sched_yield is static inline in QuRT sys/sched.h, so there is no
    // linkable symbol in the SDK libraries.  Programs must provide their own
    // implementation or use --defsym=sched_yield=abort at link time.
    pub fn sched_yield() -> c_int;
    pub fn sched_get_priority_max(policy: c_int) -> c_int;
    pub fn sched_get_priority_min(policy: c_int) -> c_int;
}
