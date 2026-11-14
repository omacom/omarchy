//! Header: `time.h`

use super::*;
use crate::prelude::*;

// Clock types
pub const CLOCK_REALTIME: clockid_t = 0;
pub const CLOCK_MONOTONIC: clockid_t = 1;
pub const CLOCK_THREAD_CPUTIME_ID: clockid_t = 2;
pub const CLOCK_PROCESS_CPUTIME_ID: clockid_t = 3;

extern "C" {
    pub fn time(tloc: *mut time_t) -> time_t;
    pub fn clock() -> clock_t;
    pub fn difftime(time1: time_t, time0: time_t) -> c_double;
    pub fn mktime(tm: *mut tm) -> time_t;
    pub fn gmtime(timep: *const time_t) -> *mut tm;
    pub fn gmtime_r(timep: *const time_t, result: *mut tm) -> *mut tm;
    pub fn localtime(timep: *const time_t) -> *mut tm;
    pub fn localtime_r(timep: *const time_t, result: *mut tm) -> *mut tm;
    pub fn asctime(tm: *const tm) -> *mut c_char;
    pub fn asctime_r(tm: *const tm, buf: *mut c_char) -> *mut c_char;
    pub fn ctime(timep: *const time_t) -> *mut c_char;
    pub fn ctime_r(timep: *const time_t, buf: *mut c_char) -> *mut c_char;
    pub fn strftime(
        s: *mut c_char,
        maxsize: size_t,
        format: *const c_char,
        timeptr: *const tm,
    ) -> size_t;
    pub fn strptime(s: *const c_char, format: *const c_char, tm: *mut tm) -> *mut c_char;
    pub fn clock_gettime(clk_id: clockid_t, tp: *mut timespec) -> c_int;
    pub fn nanosleep(req: *const timespec, rem: *mut timespec) -> c_int;

    // POSIX timer functions (from QuRT time.h)
    pub fn timer_create(clockid: clockid_t, evp: *mut sigevent, timerid: *mut timer_t) -> c_int;
    pub fn timer_delete(timerid: timer_t) -> c_int;
    pub fn timer_gettime(timerid: timer_t, value: *mut itimerspec) -> c_int;
    pub fn timer_settime(
        timerid: timer_t,
        flags: c_int,
        value: *const itimerspec,
        ovalue: *mut itimerspec,
    ) -> c_int;
}
