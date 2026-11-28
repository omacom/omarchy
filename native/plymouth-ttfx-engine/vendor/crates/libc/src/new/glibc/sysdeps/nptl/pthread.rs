//! Source header: `sysdeps/nptl/pthread.h`
//!
//! <https://github.com/bminor/glibc/blob/master/sysdeps/nptl/pthread.h>

use super::bits::struct_mutex::*;
use crate::prelude::*;

c_enum! {
    #[repr(c_int)]
    enum #anon {
        PTHREAD_MUTEX_TIMED_NP,
        PTHREAD_MUTEX_RECURSIVE_NP,
        PTHREAD_MUTEX_ERRORCHECK_NP,
        pub PTHREAD_MUTEX_ADAPTIVE_NP,
    }
}

pub const PTHREAD_MUTEX_INITIALIZER: crate::pthread_mutex_t =
    __PTHREAD_MUTEX_INITIALIZER(PTHREAD_MUTEX_TIMED_NP);
pub const PTHREAD_RECURSIVE_MUTEX_INITIALIZER_NP: crate::pthread_mutex_t =
    __PTHREAD_MUTEX_INITIALIZER(PTHREAD_MUTEX_RECURSIVE_NP);
pub const PTHREAD_ERRORCHECK_MUTEX_INITIALIZER_NP: crate::pthread_mutex_t =
    __PTHREAD_MUTEX_INITIALIZER(PTHREAD_MUTEX_ERRORCHECK_NP);
pub const PTHREAD_ADAPTIVE_MUTEX_INITIALIZER_NP: crate::pthread_mutex_t =
    __PTHREAD_MUTEX_INITIALIZER(PTHREAD_MUTEX_ADAPTIVE_NP);

pub use crate::new::common::linux_like::pthread::{
    pthread_getaffinity_np,
    pthread_getattr_np,
    pthread_getname_np,
    pthread_setaffinity_np,
    pthread_setname_np,
};
pub use crate::new::common::posix::pthread::{
    pthread_atfork,
    pthread_attr_getguardsize,
    pthread_attr_getinheritsched,
    pthread_attr_getschedparam,
    pthread_attr_getschedpolicy,
    pthread_attr_getstack,
    pthread_attr_setguardsize,
    pthread_attr_setinheritsched,
    pthread_attr_setschedparam,
    pthread_attr_setschedpolicy,
    pthread_attr_setstack,
    pthread_barrier_destroy,
    pthread_barrier_init,
    pthread_barrier_wait,
    pthread_barrierattr_destroy,
    pthread_barrierattr_getpshared,
    pthread_barrierattr_init,
    pthread_barrierattr_setpshared,
    pthread_cancel,
    pthread_condattr_getclock,
    pthread_condattr_getpshared,
    pthread_condattr_setclock,
    pthread_condattr_setpshared,
    pthread_create,
    pthread_getcpuclockid,
    pthread_getschedparam,
    pthread_kill,
    pthread_mutex_consistent,
    pthread_mutex_timedlock,
    pthread_mutexattr_getprotocol,
    pthread_mutexattr_getpshared,
    pthread_mutexattr_getrobust,
    pthread_mutexattr_setprotocol,
    pthread_mutexattr_setpshared,
    pthread_mutexattr_setrobust,
    pthread_once,
    pthread_rwlockattr_getpshared,
    pthread_rwlockattr_setpshared,
    pthread_setschedparam,
    pthread_setschedprio,
    pthread_sigmask,
    pthread_spin_destroy,
    pthread_spin_init,
    pthread_spin_lock,
    pthread_spin_trylock,
    pthread_spin_unlock,
};
