//! Header: `pthread.h`
//!
//! QuRT provides a subset of POSIX pthread functionality optimized for real-time systems.

use super::*;
use crate::prelude::*;

// Thread creation attributes (QuRT values differ from POSIX/Linux defaults)
pub const PTHREAD_CREATE_DETACHED: c_int = 0;
pub const PTHREAD_CREATE_JOINABLE: c_int = 1;

// Mutex types (QuRT values differ from POSIX/Linux defaults)
pub const PTHREAD_MUTEX_ERRORCHECK: c_int = 0;
pub const PTHREAD_MUTEX_NORMAL: c_int = 1;
pub const PTHREAD_MUTEX_RECURSIVE: c_int = 2;
pub const PTHREAD_MUTEX_DEFAULT: c_int = 3;

// Process sharing
pub const PTHREAD_PROCESS_PRIVATE: c_int = 0;
pub const PTHREAD_PROCESS_SHARED: c_int = 1;

// Mutex protocol
pub const PTHREAD_PRIO_NONE: c_int = 0;
pub const PTHREAD_PRIO_INHERIT: c_int = 1;
pub const PTHREAD_PRIO_PROTECT: c_int = 2;

// Thread priority constants
pub const PTHREAD_MIN_PRIORITY: c_int = 0;
pub const PTHREAD_MAX_PRIORITY: c_int = 255;

// Initializer constants
pub const PTHREAD_MUTEX_INITIALIZER: pthread_mutex_t = 0xFFFFFFFF;
pub const PTHREAD_COND_INITIALIZER: pthread_cond_t = 0xFFFFFFFF;
pub const PTHREAD_RWLOCK_INITIALIZER: pthread_rwlock_t = !0usize as pthread_rwlock_t;
pub const PTHREAD_ONCE_INIT: pthread_once_t = 0;

// Stack size
pub const PTHREAD_STACK_MIN: size_t = 8192;

// Contention scope
pub const PTHREAD_SCOPE_SYSTEM: c_int = 0;
pub const PTHREAD_SCOPE_PROCESS: c_int = 1;

// Scheduler inheritance (QuRT values differ from POSIX/Linux defaults)
pub const PTHREAD_EXPLICIT_SCHED: c_int = 0;
pub const PTHREAD_INHERIT_SCHED: c_int = 1;

extern "C" {
    // Thread management
    pub fn pthread_create(
        thread: *mut pthread_t,
        attr: *const pthread_attr_t,
        start_routine: extern "C" fn(*mut c_void) -> *mut c_void,
        arg: *mut c_void,
    ) -> c_int;
    pub fn pthread_join(thread: pthread_t, retval: *mut *mut c_void) -> c_int;
    pub fn pthread_detach(thread: pthread_t) -> c_int;
    pub fn pthread_exit(retval: *mut c_void) -> !;
    pub fn pthread_self() -> pthread_t;
    // Note: pthread_equal is static inline in QuRT pthread.h, no linkable symbol
    pub fn pthread_cancel(thread: pthread_t) -> c_int;
    pub fn pthread_kill(thread: pthread_t, sig: c_int) -> c_int;
    pub fn pthread_setcancelstate(state: c_int, oldstate: *mut c_int) -> c_int;
    pub fn pthread_setcanceltype(r#type: c_int, oldtype: *mut c_int) -> c_int;

    // Thread scheduling
    pub fn pthread_getschedparam(
        thread: pthread_t,
        policy: *mut c_int,
        param: *mut sched_param,
    ) -> c_int;
    pub fn pthread_setschedparam(
        thread: pthread_t,
        policy: c_int,
        param: *const sched_param,
    ) -> c_int;
    pub fn pthread_setschedprio(thread: pthread_t, prio: c_int) -> c_int;

    // Thread attributes
    pub fn pthread_attr_init(attr: *mut pthread_attr_t) -> c_int;
    pub fn pthread_attr_destroy(attr: *mut pthread_attr_t) -> c_int;
    pub fn pthread_attr_setstacksize(attr: *mut pthread_attr_t, stacksize: size_t) -> c_int;
    pub fn pthread_attr_getstacksize(attr: *const pthread_attr_t, stacksize: *mut size_t) -> c_int;
    pub fn pthread_attr_setstackaddr(attr: *mut pthread_attr_t, stackaddr: *mut c_void) -> c_int;
    pub fn pthread_attr_getstackaddr(
        attr: *const pthread_attr_t,
        stackaddr: *mut *mut c_void,
    ) -> c_int;
    pub fn pthread_attr_setstack(
        attr: *mut pthread_attr_t,
        stackaddr: *mut c_void,
        stacksize: size_t,
    ) -> c_int;
    pub fn pthread_attr_getstack(
        attr: *const pthread_attr_t,
        stackaddr: *mut *mut c_void,
        stacksize: *mut size_t,
    ) -> c_int;
    pub fn pthread_attr_setdetachstate(attr: *mut pthread_attr_t, detachstate: c_int) -> c_int;
    pub fn pthread_attr_getdetachstate(
        attr: *const pthread_attr_t,
        detachstate: *mut c_int,
    ) -> c_int;
    pub fn pthread_attr_setscope(attr: *mut pthread_attr_t, scope: c_int) -> c_int;
    pub fn pthread_attr_getscope(attr: *const pthread_attr_t, scope: *mut c_int) -> c_int;
    pub fn pthread_attr_setinheritsched(attr: *mut pthread_attr_t, inheritsched: c_int) -> c_int;
    pub fn pthread_attr_getinheritsched(
        attr: *const pthread_attr_t,
        inheritsched: *mut c_int,
    ) -> c_int;
    pub fn pthread_attr_setschedparam(
        attr: *mut pthread_attr_t,
        param: *const sched_param,
    ) -> c_int;
    pub fn pthread_attr_getschedparam(
        attr: *const pthread_attr_t,
        param: *mut sched_param,
    ) -> c_int;
    pub fn pthread_attr_getguardsize(attr: *const pthread_attr_t, guardsize: *mut size_t) -> c_int;

    // Mutex operations
    pub fn pthread_mutex_init(
        mutex: *mut pthread_mutex_t,
        attr: *const pthread_mutexattr_t,
    ) -> c_int;
    pub fn pthread_mutex_destroy(mutex: *mut pthread_mutex_t) -> c_int;
    pub fn pthread_mutex_lock(mutex: *mut pthread_mutex_t) -> c_int;
    pub fn pthread_mutex_trylock(mutex: *mut pthread_mutex_t) -> c_int;
    pub fn pthread_mutex_unlock(mutex: *mut pthread_mutex_t) -> c_int;
    pub fn pthread_mutex_getprioceiling(
        mutex: *const pthread_mutex_t,
        prioceiling: *mut c_int,
    ) -> c_int;
    pub fn pthread_mutex_setprioceiling(
        mutex: *mut pthread_mutex_t,
        prioceiling: c_int,
        old_ceiling: *mut c_int,
    ) -> c_int;

    // Mutex attributes
    pub fn pthread_mutexattr_init(attr: *mut pthread_mutexattr_t) -> c_int;
    pub fn pthread_mutexattr_destroy(attr: *mut pthread_mutexattr_t) -> c_int;
    pub fn pthread_mutexattr_settype(attr: *mut pthread_mutexattr_t, kind: c_int) -> c_int;
    pub fn pthread_mutexattr_gettype(attr: *const pthread_mutexattr_t, kind: *mut c_int) -> c_int;
    pub fn pthread_mutexattr_setprotocol(attr: *mut pthread_mutexattr_t, protocol: c_int) -> c_int;
    pub fn pthread_mutexattr_getprotocol(
        attr: *const pthread_mutexattr_t,
        protocol: *mut c_int,
    ) -> c_int;
    pub fn pthread_mutexattr_setpshared(attr: *mut pthread_mutexattr_t, pshared: c_int) -> c_int;
    pub fn pthread_mutexattr_getpshared(
        attr: *const pthread_mutexattr_t,
        pshared: *mut c_int,
    ) -> c_int;
    pub fn pthread_mutexattr_setprioceiling(
        attr: *mut pthread_mutexattr_t,
        prioceiling: c_int,
    ) -> c_int;
    pub fn pthread_mutexattr_getprioceiling(
        attr: *const pthread_mutexattr_t,
        prioceiling: *mut c_int,
    ) -> c_int;

    // Condition variables
    pub fn pthread_cond_init(cond: *mut pthread_cond_t, attr: *const pthread_condattr_t) -> c_int;
    pub fn pthread_cond_destroy(cond: *mut pthread_cond_t) -> c_int;
    pub fn pthread_cond_wait(cond: *mut pthread_cond_t, mutex: *mut pthread_mutex_t) -> c_int;
    pub fn pthread_cond_timedwait(
        cond: *mut pthread_cond_t,
        mutex: *mut pthread_mutex_t,
        abstime: *const timespec,
    ) -> c_int;
    pub fn pthread_cond_signal(cond: *mut pthread_cond_t) -> c_int;
    pub fn pthread_cond_broadcast(cond: *mut pthread_cond_t) -> c_int;

    // Condition variable attributes
    pub fn pthread_condattr_init(attr: *mut pthread_condattr_t) -> c_int;
    pub fn pthread_condattr_destroy(attr: *mut pthread_condattr_t) -> c_int;
    pub fn pthread_condattr_setclock(attr: *mut pthread_condattr_t, clock_id: clockid_t) -> c_int;
    pub fn pthread_condattr_getclock(
        attr: *const pthread_condattr_t,
        clock_id: *mut clockid_t,
    ) -> c_int;
    pub fn pthread_condattr_setpshared(attr: *mut pthread_condattr_t, pshared: c_int) -> c_int;
    pub fn pthread_condattr_getpshared(
        attr: *const pthread_condattr_t,
        pshared: *mut c_int,
    ) -> c_int;

    // Spinlocks
    pub fn pthread_spin_init(lock: *mut pthread_spinlock_t, pshared: c_int) -> c_int;
    pub fn pthread_spin_destroy(lock: *mut pthread_spinlock_t) -> c_int;
    pub fn pthread_spin_lock(lock: *mut pthread_spinlock_t) -> c_int;
    pub fn pthread_spin_trylock(lock: *mut pthread_spinlock_t) -> c_int;
    pub fn pthread_spin_unlock(lock: *mut pthread_spinlock_t) -> c_int;

    // Barriers
    pub fn pthread_barrier_init(
        barrier: *mut pthread_barrier_t,
        attr: *const pthread_barrierattr_t,
        count: c_uint,
    ) -> c_int;
    pub fn pthread_barrier_destroy(barrier: *mut pthread_barrier_t) -> c_int;
    pub fn pthread_barrier_wait(barrier: *mut pthread_barrier_t) -> c_int;
    pub fn pthread_barrierattr_init(attr: *mut pthread_barrierattr_t) -> c_int;
    pub fn pthread_barrierattr_destroy(attr: *mut pthread_barrierattr_t) -> c_int;
    pub fn pthread_barrierattr_getpshared(
        attr: *const pthread_barrierattr_t,
        pshared: *mut c_int,
    ) -> c_int;
    pub fn pthread_barrierattr_setpshared(
        attr: *mut pthread_barrierattr_t,
        pshared: c_int,
    ) -> c_int;

    // Read-write locks
    pub fn pthread_rwlock_init(
        rwlock: *mut pthread_rwlock_t,
        attr: *const pthread_rwlockattr_t,
    ) -> c_int;
    pub fn pthread_rwlock_destroy(rwlock: *mut pthread_rwlock_t) -> c_int;
    pub fn pthread_rwlock_rdlock(rwlock: *mut pthread_rwlock_t) -> c_int;
    pub fn pthread_rwlock_tryrdlock(rwlock: *mut pthread_rwlock_t) -> c_int;
    pub fn pthread_rwlock_wrlock(rwlock: *mut pthread_rwlock_t) -> c_int;
    pub fn pthread_rwlock_trywrlock(rwlock: *mut pthread_rwlock_t) -> c_int;
    pub fn pthread_rwlock_unlock(rwlock: *mut pthread_rwlock_t) -> c_int;
    pub fn pthread_rwlockattr_init(attr: *mut pthread_rwlockattr_t) -> c_int;
    pub fn pthread_rwlockattr_destroy(attr: *mut pthread_rwlockattr_t) -> c_int;
    pub fn pthread_rwlockattr_getpshared(
        attr: *const pthread_rwlockattr_t,
        pshared: *mut c_int,
    ) -> c_int;
    pub fn pthread_rwlockattr_setpshared(attr: *mut pthread_rwlockattr_t, pshared: c_int) -> c_int;

    // Thread-local storage
    pub fn pthread_key_create(
        key: *mut pthread_key_t,
        destructor: Option<extern "C" fn(*mut c_void)>,
    ) -> c_int;
    pub fn pthread_key_delete(key: pthread_key_t) -> c_int;
    pub fn pthread_getspecific(key: pthread_key_t) -> *mut c_void;
    pub fn pthread_setspecific(key: pthread_key_t, value: *const c_void) -> c_int;

    // One-time initialization
    pub fn pthread_once(once_control: *mut pthread_once_t, init_routine: extern "C" fn()) -> c_int;

    // GNU/QuRT non-portable extensions
    pub fn pthread_getname_np(thread: pthread_t, name: *mut c_char, len: size_t) -> c_int;
    pub fn pthread_getattr_np(thread: pthread_t, attr: *mut pthread_attr_t) -> c_int;
    pub fn pthread_attr_setaffinity_np(
        attr: *mut pthread_attr_t,
        cpusetsize: size_t,
        cpuset: *const cpu_set_t,
    ) -> c_int;
    pub fn pthread_attr_getaffinity_np(
        attr: *mut pthread_attr_t,
        cpusetsize: size_t,
        cpuset: *mut cpu_set_t,
    ) -> c_int;

    // QuRT-specific thread attribute extensions
    pub fn pthread_attr_setthreadname(attr: *mut pthread_attr_t, name: *const c_char) -> c_int;
    pub fn pthread_attr_getthreadname(
        attr: *const pthread_attr_t,
        name: *mut c_char,
        size: c_int,
    ) -> c_int;
    pub fn pthread_attr_settimetestid(attr: *mut pthread_attr_t, tid: c_uint) -> c_int;
    pub fn pthread_attr_gettimetestid(attr: *const pthread_attr_t, tid: *mut c_uint) -> c_int;
    pub fn pthread_attr_setautostack(attr: *mut pthread_attr_t) -> c_int;
    pub fn pthread_attr_setbuspriority(attr: *mut pthread_attr_t, bus_priority: c_ushort) -> c_int;

    // POSIX standard (declared in QuRT pthread.h)
    pub fn posix_memalign(memptr: *mut *mut c_void, alignment: size_t, size: size_t) -> c_int;
}
