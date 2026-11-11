//! Unchecked slice access for the fixed-size and SIMD kernels.
//!
//! Every helper reads or writes the run of elements (or vector bytes) that
//! starts at index `i`, and that run must lie inside the slice. The kernels
//! index by construction (whole groups of lanes in arrays sized for them,
//! rows and pools kept with slack past their content; see fx::At), so only
//! debug builds check.

/// `a[i..i + N]` as an array.
#[inline(always)]
pub fn load<T: Copy, const N: usize>(a: &[T], i: usize) -> [T; N] {
    debug_assert!(i + N <= a.len(), "{N} at {i} out of bounds ({})", a.len());
    // SAFETY: in bounds by construction (see the module); unaligned.
    unsafe { std::ptr::read_unaligned(a.as_ptr().add(i) as *const [T; N]) }
}

/// `a[i..i + N] = v`.
#[inline(always)]
pub fn store<T: Copy, const N: usize>(a: &mut [T], i: usize, v: [T; N]) {
    debug_assert!(i + N <= a.len(), "{N} at {i} out of bounds ({})", a.len());
    // SAFETY: in bounds by construction (see the module); unaligned.
    unsafe { std::ptr::write_unaligned(a.as_mut_ptr().add(i) as *mut [T; N], v) }
}

/// Element types an integer vector may load from and store to: no padding,
/// and every bit pattern is a value.
#[cfg(any(target_arch = "x86_64", target_arch = "aarch64"))]
pub trait Plain: Copy + sealed::Sealed {}
#[cfg(any(target_arch = "x86_64", target_arch = "aarch64"))]
impl<T: Copy + sealed::Sealed> Plain for T {}

#[cfg(any(target_arch = "x86_64", target_arch = "aarch64"))]
mod sealed {
    pub trait Sealed {}
    impl Sealed for u8 {}
    impl Sealed for u32 {}
    impl Sealed for i32 {}
    impl Sealed for u64 {}
    impl Sealed for i64 {}
    // repr(C), two i64s
    impl Sealed for crate::utils::geometry::Coord {}
}

/// The `bytes` from element `i` lie inside `a`.
#[cfg(any(target_arch = "x86_64", target_arch = "aarch64"))]
#[inline(always)]
fn fits<T>(a: &[T], i: usize, bytes: usize) -> bool {
    i * size_of::<T>() + bytes <= size_of_val(a)
}

#[cfg(target_arch = "x86_64")]
pub use x86::*;

#[cfg(target_arch = "x86_64")]
// calling one needs only its target feature, which the kernels have
#[allow(clippy::missing_safety_doc)]
mod x86 {
    use std::arch::x86_64::*;
    use std::mem::size_of;

    use super::{fits, Plain};

    /// Unaligned vector access to `a` from element `i`.
    macro_rules! access {
        ($feature:literal, $load:ident, $load2:ident, $store:ident, $vec:ty, [$($g:tt)*] $elem:ty, $ld:ident, $st:ident, $cast:ty) => {
            #[target_feature(enable = $feature)]
            #[inline]
            pub fn $load<$($g)*>(a: &[$elem], i: usize) -> $vec {
                debug_assert!(fits(a, i, size_of::<$vec>()));
                // SAFETY: in bounds by construction (see the module).
                unsafe { $ld(a.as_ptr().add(i) as *const $cast) }
            }

            /// Two vectors in a row.
            #[target_feature(enable = $feature)]
            #[inline]
            pub fn $load2<$($g)*>(a: &[$elem], i: usize) -> [$vec; 2] {
                debug_assert!(fits(a, i, 2 * size_of::<$vec>()));
                // SAFETY: in bounds by construction (see the module).
                unsafe {
                    let p = a.as_ptr().add(i) as *const $vec;
                    [$ld(p as *const $cast), $ld(p.add(1) as *const $cast)]
                }
            }

            #[target_feature(enable = $feature)]
            #[inline]
            pub fn $store<$($g)*>(a: &mut [$elem], i: usize, v: $vec) {
                debug_assert!(fits(a, i, size_of::<$vec>()));
                // SAFETY: in bounds by construction (see the module).
                unsafe { $st(a.as_mut_ptr().add(i) as *mut $cast, v) }
            }
        };
    }

    access!("sse2", load_si128, load2_si128, store_si128, __m128i, [T: Plain] T, _mm_loadu_si128, _mm_storeu_si128, __m128i);
    access!("avx", load_si256, load2_si256, store_si256, __m256i, [T: Plain] T, _mm256_loadu_si256, _mm256_storeu_si256, __m256i);
    access!("avx512f", load_si512, load2_si512, store_si512, __m512i, [T: Plain] T, _mm512_loadu_si512, _mm512_storeu_si512, __m512i);
    access!("avx", load_pd, load2_pd, store_pd, __m256d, [] f64, _mm256_loadu_pd, _mm256_storeu_pd, f64);
    access!("avx512f", load_pd8, load2_pd8, store_pd8, __m512d, [] f64, _mm512_loadu_pd, _mm512_storeu_pd, f64);

    /// `a[i..i + 4] = v` in the lanes whose `mask` has the sign bit set.
    #[target_feature(enable = "avx")]
    #[inline]
    pub fn maskstore_pd(a: &mut [f64], i: usize, mask: __m256i, v: __m256d) {
        debug_assert!(i + 4 <= a.len());
        // SAFETY: in bounds by construction (see the module).
        unsafe { _mm256_maskstore_pd(a.as_mut_ptr().add(i), mask, v) }
    }

    /// `a[i..i + 8] = v` in the lanes set in `mask`.
    #[target_feature(enable = "avx512f")]
    #[inline]
    pub fn mask_store_pd8(a: &mut [f64], i: usize, mask: __mmask8, v: __m512d) {
        debug_assert!(i + 8 <= a.len());
        // SAFETY: in bounds by construction (see the module).
        unsafe { _mm512_mask_storeu_pd(a.as_mut_ptr().add(i), mask, v) }
    }
}

#[cfg(target_arch = "aarch64")]
pub use arm::*;

/// NEON (baseline on aarch64, but the intrinsics still need the feature on
/// their caller): vector access, and the lane masks x86 gets from movemask.
#[cfg(target_arch = "aarch64")]
#[allow(clippy::missing_safety_doc)]
mod arm {
    use super::{fits, Plain};
    use std::arch::aarch64::*;
    use std::mem::size_of;

    /// Unaligned vector access to `a` from element `i`.
    macro_rules! access {
        ($load:ident, $store:ident, $vec:ty, [$($g:tt)*] $elem:ty, $ld:ident, $st:ident, $cast:ty) => {
            #[target_feature(enable = "neon")]
            #[inline]
            pub fn $load<$($g)*>(a: &[$elem], i: usize) -> $vec {
                debug_assert!(fits(a, i, size_of::<$vec>()));
                // SAFETY: in bounds by construction (see the module).
                unsafe { $ld(a.as_ptr().add(i) as *const $cast) }
            }

            #[target_feature(enable = "neon")]
            #[inline]
            pub fn $store<$($g)*>(a: &mut [$elem], i: usize, v: $vec) {
                debug_assert!(fits(a, i, size_of::<$vec>()));
                // SAFETY: in bounds by construction (see the module).
                unsafe { $st(a.as_mut_ptr().add(i) as *mut $cast, v) }
            }
        };
    }

    access!(load_f64x2, store_f64x2, float64x2_t, [] f64, vld1q_f64, vst1q_f64, f64);
    access!(load_u32x2, store_u32x2, uint32x2_t, [T: Plain] T, vld1_u32, vst1_u32, u32);
    access!(load_u8x64, store_u8x64, uint8x16x4_t, [T: Plain] T, vld1q_u8_x4, vst1q_u8_x4, u8);

    /// Two (i64, i64) pairs from element `i`, split: the first halves, then
    /// the second halves (Coord columns and rows).
    #[target_feature(enable = "neon")]
    #[inline]
    pub fn load_split_s64x2<T: Plain>(a: &[T], i: usize) -> int64x2x2_t {
        debug_assert!(fits(a, i, 32));
        // SAFETY: in bounds by construction (see the module).
        unsafe { vld2q_s64(a.as_ptr().add(i) as *const i64) }
    }

    /// Bit i of byte i in each group of 8, for summing byte masks into bits.
    #[target_feature(enable = "neon")]
    #[inline]
    fn byte_bits() -> uint8x16_t {
        let b = vcreate_u8(0x8040_2010_0804_0201);
        vcombine_u8(b, b)
    }

    /// movemask of 64 byte masks (all ones or zero): bit i from byte i.
    #[target_feature(enable = "neon")]
    #[inline]
    pub fn bits_u8x64(m: uint8x16x4_t) -> u64 {
        let bits = byte_bits();
        let b = |v: uint8x16_t| vandq_u8(v, bits);
        let ab = vpaddq_u8(b(m.0), b(m.1));
        let cd = vpaddq_u8(b(m.2), b(m.3));
        let abcd = vpaddq_u8(ab, cd);
        vgetq_lane_u64::<0>(vreinterpretq_u64_u8(vpaddq_u8(abcd, abcd)))
    }

    /// movemask of 16 byte masks (all ones or zero): bit i from byte i.
    #[target_feature(enable = "neon")]
    #[inline]
    pub fn bits_u8x16(m: uint8x16_t) -> u32 {
        let t = vandq_u8(m, byte_bits());
        let t = vpaddq_u8(t, t);
        let t = vpaddq_u8(t, t);
        let t = vpaddq_u8(t, t);
        vgetq_lane_u16::<0>(vreinterpretq_u16_u8(t)) as u32
    }

    /// movemask of two u64 lane masks (all ones or zero).
    #[target_feature(enable = "neon")]
    #[inline]
    pub fn bits_u64x2(m: uint64x2_t) -> u32 {
        vaddvq_u64(vandq_u64(m, vcombine_u64(vcreate_u64(1), vcreate_u64(2)))) as u32
    }

    /// Bits 0-1 of `lanes` as a lane mask.
    #[target_feature(enable = "neon")]
    #[inline]
    pub fn lane_mask2(lanes: u32) -> uint64x2_t {
        vtstq_u64(
            vdupq_n_u64(lanes as u64),
            vcombine_u64(vcreate_u64(1), vcreate_u64(2)),
        )
    }

    /// Two u32 lane masks widened to u64 lane masks.
    #[target_feature(enable = "neon")]
    #[inline]
    pub fn widen_mask2(m: uint32x2_t) -> uint64x2_t {
        vreinterpretq_u64_s64(vmovl_s32(vreinterpret_s32_u32(m)))
    }
}

#[cfg(all(test, target_arch = "aarch64"))]
mod tests {
    use super::*;
    use std::arch::aarch64::*;

    #[target_feature(enable = "neon")]
    fn masks(bytes: &[u8; 64]) -> (u64, u32, [u32; 4]) {
        let q = load_u8x64(bytes, 0);
        let lanes = [0, 1, 2, 3].map(|l| bits_u64x2(lane_mask2(l)));
        (bits_u8x64(q), bits_u8x16(q.0), lanes)
    }

    #[test]
    fn lane_masks_match_scalar() {
        let mut x = 0x9e37_79b9_7f4a_7c15u64;
        for _ in 0..10_000 {
            let mut bytes = [0u8; 64];
            for b in &mut bytes {
                x = x
                    .wrapping_mul(6_364_136_223_846_793_005)
                    .wrapping_add(1_442_695_040_888_963_407);
                *b = if x >> 63 != 0 { 0xff } else { 0 };
            }
            let want = bytes
                .iter()
                .enumerate()
                .fold(0u64, |m, (i, &b)| m | ((b != 0) as u64) << i);
            // SAFETY: NEON is baseline on aarch64.
            let (all, first, lanes) = unsafe { masks(&bytes) };
            assert_eq!(all, want);
            assert_eq!(first, want as u32 & 0xffff);
            assert_eq!(lanes, [0, 1, 2, 3]);
        }
    }
}
