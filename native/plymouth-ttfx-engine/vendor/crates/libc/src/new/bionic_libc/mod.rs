//! This directory maps to `bionic/libc/include` in the Android source. `bionic/libc/kernel` is
//! the source of UAPI definitions, which are a cleaned form of the default Linux headers.
//!
//! <https://cs.android.com/android/platform/superproject/main/+/main:bionic/libc/include/>,
//! <https://cs.android.com/android/platform/superproject/main/+/main:bionic/libc/kernel/uapi/>

pub(crate) mod kernel_uapi;
pub(crate) mod pthread;
pub(crate) mod sys;
pub(crate) mod unistd;
