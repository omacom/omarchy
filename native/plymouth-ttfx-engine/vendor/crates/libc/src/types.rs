//! Platform-agnostic support types.

#[cfg(feature = "extra_traits")]
use core::hash::Hash;
use core::mem::MaybeUninit;

use crate::prelude::*;

/// A transparent wrapper over `MaybeUninit<T>` to represent uninitialized padding
/// while providing `Default`.
// This is restricted to `Copy` types since that's a loose indicator that zeros is actually
// a valid bitpattern. There is no technical reason this is required, though, so it could be
// lifted in the future if it becomes a problem.
#[allow(dead_code)]
#[repr(transparent)]
#[derive(Clone, Copy)]
pub(crate) struct Padding<T: Copy>(MaybeUninit<T>);

impl<T: Copy> Default for Padding<T> {
    fn default() -> Self {
        Self(MaybeUninit::zeroed())
    }
}

impl<T: Copy> Padding<T> {
    /// Create a `Padding` initialized with the given value.
    #[allow(dead_code)]
    pub(crate) const fn new(val: T) -> Self {
        Self(MaybeUninit::new(val))
    }
}

impl<T: Copy> fmt::Debug for Padding<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        // Taken from `MaybeUninit`'s debug implementation
        // NB: there is no `.pad_fmt` so we can't use a simpler `format_args!("Padding<{..}>").
        let full_name = core::any::type_name::<Self>();
        let prefix_len = full_name.find("Padding").unwrap();
        f.pad(&full_name[prefix_len..])
    }
}

/// Do nothing when hashing to ignore the existence of padding fields.
#[cfg(feature = "extra_traits")]
impl<T: Copy> Hash for Padding<T> {
    fn hash<H: hash::Hasher>(&self, _state: &mut H) {}
}

/// Padding fields are all equal, regardless of what is inside them, so they do not affect anything.
#[cfg(feature = "extra_traits")]
impl<T: Copy> PartialEq for Padding<T> {
    fn eq(&self, _other: &Self) -> bool {
        true
    }
}

/// Mark that `Padding` implements `Eq` so that it can be used in types that implement it.
#[cfg(feature = "extra_traits")]
impl<T: Copy> Eq for Padding<T> {}

/// The default repr type used for C style enums in Rust.
#[cfg(target_env = "msvc")]
#[allow(unused)]
pub(crate) type CEnumRepr = c_int;
#[cfg(not(target_env = "msvc"))]
#[allow(unused)]
pub(crate) type CEnumRepr = c_uint;

/// Used to avoid `overflowing_literals` when the value is in-range for the unsigned number but
/// out-of-range for signed.
#[allow(unused)]
pub(crate) const fn u16_cast_short(x: u16) -> c_short {
    assert!(size_of::<u16>() <= size_of::<c_short>()); // Should always be true
    x as i16
}

/// Used to avoid `overflowing_literals` when the value is in-range for the unsigned number but
/// out-of-range for signed.
#[allow(unused)]
pub(crate) const fn u32_cast_int(x: u32) -> c_int {
    // May not be true on 16-bit platforms, but should be everywhere this is used.
    assert!(size_of::<u32>() <= size_of::<c_int>());
    x as i32
}

/// Used to avoid `overflowing_literals` when the value is in-range for the unsigned number but
/// out-of-range for signed.
#[allow(unused)]
pub(crate) const fn u32_cast_long(x: u32) -> c_long {
    assert!(size_of::<u32>() <= size_of::<c_long>()); // Should always be true
    x as c_long
}

/// Checked casting from `unsigned long` to `int`.
#[allow(unused)]
pub(crate) const fn ulong_cast_int(x: c_ulong) -> c_int {
    assert!(x <= (c_int::MAX as c_ulong));
    x as c_int
}

/// Checked casting from `unsigned long` to `unsigned int`.
#[allow(unused)]
pub(crate) const fn ulong_cast_uint(x: c_ulong) -> c_uint {
    assert!(x <= (c_uint::MAX as c_ulong));
    x as c_uint
}

/// Used to avoid `overflowing_literals` when the value is in-range for the unsigned number but
/// out-of-range for signed.
#[allow(unused)]
#[cfg(any(target_os = "linux", target_os = "android", target_os = "l4re"))]
pub(crate) const fn u32_cast_ioctl(x: u32) -> crate::Ioctl {
    assert!(size_of::<u32>() <= size_of::<crate::Ioctl>()); // Should always be true
    x as crate::Ioctl
}

#[allow(unused)]
pub(crate) const fn u8_slice_cast_char_slice(x: &[u8]) -> &[c_char] {
    assert!(size_of::<u8>() == size_of::<c_char>());
    // SAFETY: same repr, possibly just a sign cast
    unsafe { mem::transmute::<&[u8], &[c_char]>(x) }
}

/// Replace bytes in an array with those from a slice. This is a polyfill for `[T]::copy_from_slice`
/// in `const`.
// FIXME(msrv): we can switch to `copy_from_slice` in 1.87.
#[must_use]
#[allow(dead_code)]
pub const fn replace_array_items<T: Copy, const N: usize>(
    mut dst: [T; N],
    src: &[T],
    start: usize,
) -> [T; N] {
    let mut i = 0;
    while i < src.len() {
        dst[i + start] = src[i];
        i += 1;
    }
    dst
}
