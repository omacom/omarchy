//! VxWorks libc.
//!
//! VxWorks allows compiling different types of programs. The `libc` crate only
//! supports RTPs. Refer to the RTP definitions in case of discrepancy.
// FIXME(vxworks): link to headers needed.

pub(crate) mod unistd;
