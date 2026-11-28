//! Source directory: `sysdeps/nptl/`o
//!
//! Native POSIX threading library.
//!
//! <https://github.com/bminor/glibc/tree/master/sysdeps/nptl>

pub(crate) mod bits {
    #[cfg_attr(
        any(
            target_arch = "mips",
            target_arch = "mips32r6",
            target_arch = "mips",
            target_arch = "mips32r6",
        ),
        path = "../../mips/nptl/bits/struct_mutex.rs"
    )]
    #[cfg_attr(
        any(target_arch = "powerpc", target_arch = "powerpc64"),
        path = "../../powerpc/nptl/bits/struct_mutex.rs"
    )]
    #[cfg_attr(target_arch = "s390x", path = "../../s390/nptl/bits/struct_mutex.rs")]
    #[cfg_attr(
        any(target_arch = "x86", target_arch = "x86_64"),
        path = "../../x86/nptl/bits/struct_mutex.rs"
    )]
    pub(crate) mod struct_mutex;
}

pub(crate) mod pthread;
