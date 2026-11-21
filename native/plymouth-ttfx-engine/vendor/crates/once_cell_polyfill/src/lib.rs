//! > Polyfill for `OnceCell` stdlib feature for use with older MSRVs

#![warn(clippy::print_stderr)]
#![warn(clippy::print_stdout)]

pub mod sync;

#[doc = include_str!("../README.md")]
#[cfg(doctest)]
pub struct ReadmeDoctests;
