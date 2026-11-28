//! Directory: `sysdeps/powerpc`

#[cfg(target_os = "linux")]
pub(crate) mod nptl {
    pub(crate) mod bits;
}
