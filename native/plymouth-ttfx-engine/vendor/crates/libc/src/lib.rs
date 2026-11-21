//! Raw FFI bindings to platform system libraries.
//!
//! # Usage Guidelines
//!
//! `libc` exposes non-Rust interfaces in Rust, which makes for some caveats to its use that are
//! not present in most Rust libraries. Observing the following guidelines are recommended to help
//! avoid soundness and stability pitfalls.
//!
//! 1. *Never* construct a `libc` struct with `MaybeUninit::uninit()`, initialize it, then call
//!    `assume_init`. Many structures have padding fields or may gain fields in the future, and
//!    it is far too easy to end up calling `assume_init` on partially initialized data.
//!
//!    Instead, use `MaybeUninit::zeroed()` or the `Default` implementations that are slowly being
//!    added. Alternatively, access fields only via raw pointer without ever using `assume_init`.
//!
//! 2. Avoid relying on the exact value of constants, the exact length of arrays, or the exact
//!    types of type aliases, as they may change across `libc` versions. That is, if `libc`
//!    contains code like:
//!
//!    <!-- relevant for how rustdoc displays these structs:
//!         https://github.com/rust-lang/rust/issues/102456 -->
//!    ```ignore
//!    const IFNAMSIZ: usize = 16;
//!
//!    pub struct ifreq {
//!        pub ifr_name: [c_char; IFNAMSIZ],
//!        // ...
//!    }
//!
//!    extern "C" {
//!        pub fn time(time: *mut time_t) -> time_t;
//!    }
//!    ```
//!
//!    Then avoid writing code like:
//!
//!    ```ignore
//!    // Bad assumption that the length will always be 16.
//!    fn takes_ifr_name(ifr_name: [c_char; 16]) { /* ... */ }
//!
//!    fn process_ifr(ifr: ifreq) {
//!        takes_ifr_name(ifr.ifr_name);
//!    }
//!
//!    // Bad assumption that `time_t` will always be an `i64`. Use `-> time_t` instead, or
//!    // explicitly cast to an `i64`.`
//!    fn get_time() -> i64 {
//!        unsafe { time(ptr::null_mut()) }
//!    }
//!
//!    ```
//!
//!    For `takes_ifr_name`, use `[c_char; IFNAMSIZ]` or just `&[c_char]` instead. For `get_time`,
//!    return a `time_t` or explicitly cast to an `i64`.
//!
//!    Along the same lines, if you write code along the lines of `assert_eq!(libc::ELAST, 97)`,
//!    expect that there may be a release where this starts to fail.
//!
//! 3. Do not name `__c_anonymous_*` types anywhere, which exist to represent anonymous fields in
//!    C. For example, FreeBSD defines:
//!
//!    ```c
//!    struct filestat {
//!        int fs_type;
//!        // ...
//!        struct { struct filestat stqe_next; } next;
//!    };
//!    ```
//!
//!    Which is represented in `libc`  as:
//!
//!    ```ignore
//!    struct filestat {
//!        fs_type: c_int,
//!        // ...
//!        next: __c_anonymous_filestat,
//!    }
//!
//!    struct __c_anonymous_filestat { stqe_next: *mut filestat }
//!    ```
//!
//!    Accessing `some_filestat.next.stqe_next` is completely fine, but `__c_anonymous_filestat`
//!    should not be used anywhere (e.g. in a function signature). This is done to permit `libc` to
//!    switch to anonymous fields if the feature is ever added to Rust.
//!
//! 4. Avoid accessing fields with names such as `__reserved`, `_pad`, or `_spare`. Usually the
//!    platform libraries use these to allow adding new fields without changing the size of a
//!    struct, but this means their types change frequently.
//!
//! 5. Be aware of deprecation warnings. These are used as a way to migrate necessary API changes.
//!
//! # Cargo Features
//!
//! - `std`: by default `libc` assumes that the standard library contains link directives necessary
//!   to use the APIs in this crate. If `std` is disabled, `libc` will emit the directives instead.
//!
//!   This feature is slated for removal in `libc` 1.0. The intention is that no-std users of
//!   `libc` should use their own `#[link]` attributes, `rustc-link-lib` build script directives,
//!   or `-l` arguments for only the system libraries they need to link, rather than `libc`
//!   possibly linking more than is needed or available. If you are using `libc` without the `std`
//!   feature, consider starting to add link directives now for a smoother 1.0 transition.
//!
//! - `extra_traits`: all types in `libc` implement `Clone`, `Copy`, and `Debug`. The
//!   `extra_traits` feature adds `Eq`, `Hash`, and `PartialEq`.
//!
//!   This feature is expected to be removed in libc 1.0. Libraries should instead hash or check
//!   equality of only needed fields.
//!
//! - The features `const-extern-fn`, `align`, and `use_std` are all deprecated and do nothing.
//!
//! # Stability Expectations
//!
//! Due to `libc`'s position in the ecosystem, it can effectively never publish semver-breaking
//! releases. However, the API that `libc` binds changes _all the time_; sometimes in ways that
//! are harmless, sometimes in ways that are technically API-breaking for all users but unlikely
//! to be noticed (e.g. removing deprecated API), and sometimes in ways that are nonbreaking in
//! C but translate to breaking changes in Rust (e.g. changing the type of an integer). `libc`
//! tries to strike a balance but all of this means that unfortunately, `libc` must occasionally
//! ship changes within a semver-compatible release that are technically semver-breaking.
//!
//! The following are examples of changes that fall into this category:
//!
//! - Fields are added to a struct that is otherwise exhaustive.
//! - Fields with names such as `padding` or `reserved` change type or are removed.
//! - The length of an array type changes.
//! - A struct field (with available padding) is changed from `int` to `long`.
//!
//! In general, `libc` aims to follow platform API changes, even when this means changes that are
//! user-visible in Rust. There are a few guidelines used here:
//!
//! - Adding struct fields is not considered breaking, nor is changing fields named `reserved`,
//!   `padding`, or similar. This is because users are expected to use field-by-field
//!   initialization.
//! - Changing type aliases, values of constants, or array lengths is not considered breaking.
//! - If the platform libc has accepted breakage on the C side (typically in the form of removing
//!   old API), the `libc` crate will follow suit.
//! - Where possible, `#[deprecated(...)]` will be used to warn about changes before applying them.
//!   Alternative mitigations may be considered.
//! - Potentially breaking changes will be well-identified in release notes.
//! - Beyond this, public API is not expected to change on Tier 1 targets. Tier 2 targets have
//!   relaxed API stability requirements, and API stability is not enforced on tier 3 targets.
//!
//! While this section seems scary, keep in mind that it is meant to cover worst-case scenarios. In
//! practice, breakage is rare and following the above-discussed [Usage Guidelines](#usage-guidelines)
//! means that most `libc` users will never encounter a problem.

// Make it a bit easier to build without Cargo
#![crate_name = "libc"]
#![crate_type = "rlib"]
// Pretty much all C API doesn't match Rust conventions.
#![allow(nonstandard_style)]
// Not all macros and all patterns are used on all targets.
#![allow(unused_macros)]
#![allow(unused_macro_rules)]
// All traits should be `Copy` and `Debug`.
#![warn(missing_copy_implementations)]
#![warn(missing_debug_implementations)]
// Downgrade deny to a warning.
#![warn(overflowing_literals)]
// Prepare for a future upgrade.
#![warn(rust_2024_compatibility)]
// Things missing for 2024 that are blocked on MSRV or breakage.
#![allow(missing_unsafe_on_extern)]
#![allow(edition_2024_expr_fragment_specifier)]
// Allowed globally, the warning is enabled in individual modules as we work through them
#![allow(unsafe_op_in_unsafe_fn)]
#![cfg_attr(libc_deny_warnings, deny(warnings))]
// Attributes needed when building as part of the standard library
#![cfg_attr(feature = "rustc-dep-of-std", feature(link_cfg, no_core))]
#![cfg_attr(feature = "rustc-dep-of-std", allow(internal_features))]
// Some targets don't need `link_cfg` and emit a warning.
#![cfg_attr(feature = "rustc-dep-of-std", allow(unused_features))]
// DIFF(1.0): The thread local references that raise this lint were removed in 1.0
#![cfg_attr(feature = "rustc-dep-of-std", allow(static_mut_refs))]
#![cfg_attr(not(feature = "rustc-dep-of-std"), no_std)]
#![cfg_attr(feature = "rustc-dep-of-std", no_core)]

#[macro_use]
mod macros;
mod new;

cfg_if! {
    if #[cfg(feature = "rustc-dep-of-std")] {
        extern crate rustc_std_workspace_core as core;
    }
}

pub use core::ffi::c_void;

#[allow(unused_imports)] // needed while the module is empty on some platforms
pub use new::*;

cfg_if! {
    if #[cfg(windows)] {
        mod primitives;
        pub use crate::primitives::*;

        mod windows;
        pub use crate::windows::*;

        prelude!();
    } else if #[cfg(target_os = "fuchsia")] {
        mod primitives;
        pub use crate::primitives::*;

        mod fuchsia;
        pub use crate::fuchsia::*;

        prelude!();
    } else if #[cfg(target_os = "switch")] {
        mod primitives;
        pub use primitives::*;

        mod switch;
        pub use switch::*;

        prelude!();
    } else if #[cfg(target_os = "psp")] {
        mod primitives;
        pub use primitives::*;

        mod psp;
        pub use crate::psp::*;

        prelude!();
    } else if #[cfg(target_os = "vxworks")] {
        mod primitives;
        pub use crate::primitives::*;

        mod vxworks;
        pub use crate::vxworks::*;

        prelude!();
    } else if #[cfg(target_os = "qurt")] {
        mod primitives;
        pub use crate::primitives::*;

        mod qurt;
        pub use crate::qurt::*;

        prelude!();
    } else if #[cfg(target_os = "solid_asp3")] {
        mod primitives;
        pub use crate::primitives::*;

        mod solid;
        pub use crate::solid::*;

        prelude!();
    } else if #[cfg(unix)] {
        mod primitives;
        pub use crate::primitives::*;

        mod unix;
        pub use crate::unix::*;

        prelude!();
    } else if #[cfg(target_os = "hermit")] {
        mod primitives;
        pub use crate::primitives::*;

        mod hermit;
        pub use crate::hermit::*;

        prelude!();
    } else if #[cfg(target_os = "teeos")] {
        mod primitives;
        pub use primitives::*;

        mod teeos;
        pub use teeos::*;

        prelude!();
    } else if #[cfg(target_os = "trusty")] {
        mod primitives;
        pub use crate::primitives::*;

        mod trusty;
        pub use crate::trusty::*;

        prelude!();
    } else if #[cfg(all(target_env = "sgx", target_vendor = "fortanix"))] {
        mod primitives;
        pub use crate::primitives::*;

        mod sgx;
        pub use crate::sgx::*;

        prelude!();
    } else if #[cfg(any(target_env = "wasi", target_os = "wasi"))] {
        mod primitives;
        pub use crate::primitives::*;

        mod wasi;
        pub use crate::wasi::*;

        prelude!();
    } else if #[cfg(target_os = "xous")] {
        mod primitives;
        pub use crate::primitives::*;

        mod xous;
        pub use crate::xous::*;

        prelude!();
    } else {
        // non-supported targets: empty...
    }
}
