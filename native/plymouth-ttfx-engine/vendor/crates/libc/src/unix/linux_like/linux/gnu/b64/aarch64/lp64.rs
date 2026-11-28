use crate::prelude::*;

pub const __SIZEOF_PTHREAD_CONDATTR_T: usize = 8;
pub const __SIZEOF_PTHREAD_MUTEX_T: usize = 48;
pub const __SIZEOF_PTHREAD_MUTEXATTR_T: usize = 8;
pub const __SIZEOF_PTHREAD_RWLOCK_T: usize = 56;
pub const __SIZEOF_PTHREAD_BARRIERATTR_T: usize = 8;
pub const __SIZEOF_PTHREAD_BARRIER_T: usize = 32;

pub const SYS_renameat: c_long = 38;
pub const SYS_sync_file_range: c_long = 84;
pub const SYS_getrlimit: c_long = 163;
pub const SYS_setrlimit: c_long = 164;
