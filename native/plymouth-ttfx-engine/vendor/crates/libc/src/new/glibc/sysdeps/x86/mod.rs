//! Directory: `sysdeps/x86`

#[cfg(target_os = "linux")]
pub(crate) mod nptl {
    pub(crate) mod bits;
}
