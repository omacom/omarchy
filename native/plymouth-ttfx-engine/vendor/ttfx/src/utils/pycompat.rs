//! Helpers reproducing Python semantics where they differ from Rust defaults.
//! Every call site that transcribes a Python `round()` or `//` must go through
//! these — see plan.md §5.

/// Python's built-in `round()`: banker's rounding (half-to-even), returning i64.
/// Rust's `f64::round` is half-away-from-zero, which differs at exact .5 values.
#[inline]
pub fn round_half_even(x: f64) -> i64 {
    // cvtsd2si rounds with MXCSR's default nearest-even mode (Rust never
    // changes it), which is round_ties_even + the cast for every value it
    // can represent; it returns i64::MIN on overflow and NaN, and that
    // (rare) result takes the full routine below. Baseline x86_64 has no
    // roundsd, so round_ties_even would be a libm call.
    #[cfg(target_arch = "x86_64")]
    {
        // SAFETY: SSE2 is baseline on x86_64.
        let r = unsafe { std::arch::x86_64::_mm_cvtsd_si64(std::arch::x86_64::_mm_set_sd(x)) };
        if r != i64::MIN {
            return r;
        }
    }
    // frintn + fcvtzs (baseline on aarch64) are round_ties_even + the
    // saturating cast, which the routine below is for every value but +inf
    // (it wraps that to i64::MIN): i64::MAX takes the routine.
    #[cfg(target_arch = "aarch64")]
    {
        let r = x.round_ties_even() as i64;
        if r != i64::MAX {
            return r;
        }
    }
    round_half_even_slow(x)
}

#[cold]
fn round_half_even_slow(x: f64) -> i64 {
    if x.is_finite() {
        return x.round_ties_even() as i64;
    }
    // Preserve the existing non-finite conversion and overflow behavior.
    let floor = x.floor();
    let diff = x - floor;
    if diff > 0.5 {
        floor as i64 + 1
    } else if diff < 0.5 {
        floor as i64
    } else {
        // exactly .5 — round to even
        let f = floor as i64;
        if f % 2 == 0 {
            f
        } else {
            f + 1
        }
    }
}

/// Python's `//` on integers: floor division. Rust's `/` truncates toward zero
/// and `div_euclid` rounds toward a non-negative remainder — both differ from
/// floor when signs are involved (7 // -2 == -4 in Python).
pub fn floor_div(a: i64, b: i64) -> i64 {
    let q = a / b;
    if a % b != 0 && (a < 0) != (b < 0) {
        q - 1
    } else {
        q
    }
}

/// Python's `%` on integers: result takes the sign of the divisor.
pub fn py_mod(a: i64, b: i64) -> i64 {
    let r = a % b;
    if r != 0 && (r < 0) != (b < 0) {
        r + b
    } else {
        r
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn round_matches_python() {
        // Golden values from CPython: round(0.5)=0, round(1.5)=2, round(2.5)=2,
        // round(-0.5)=0, round(-1.5)=-2, round(0.4999)=0, round(1.4999)=1
        assert_eq!(round_half_even(0.5), 0);
        assert_eq!(round_half_even(1.5), 2);
        assert_eq!(round_half_even(2.5), 2);
        assert_eq!(round_half_even(3.5), 4);
        assert_eq!(round_half_even(-0.5), 0);
        assert_eq!(round_half_even(-1.5), -2);
        assert_eq!(round_half_even(-2.5), -2);
        assert_eq!(round_half_even(0.4999), 0);
        assert_eq!(round_half_even(1.4999), 1);
        assert_eq!(round_half_even(2.6), 3);
        assert_eq!(round_half_even(-2.6), -3);
        // Values that aren't exactly representable don't hit the .5 branch:
        // round(2.675) == 3 in Python (2.675 is actually 2.67499999...)
        assert_eq!(round_half_even(2.675), 3);
    }

    #[test]
    fn rounding_matches_previous_arithmetic_at_boundaries_and_across_exponents() {
        fn previous(x: f64) -> i64 {
            let floor = x.floor();
            let difference = x - floor;
            let integer = floor as i64;
            if difference > 0.5 || (difference == 0.5 && integer % 2 != 0) {
                integer + 1
            } else {
                integer
            }
        }
        for integer in -10_000..=10_000 {
            let halfway = integer as f64 + 0.5;
            for value in [halfway.next_down(), halfway, halfway.next_up()] {
                assert_eq!(round_half_even(value), previous(value), "{value}");
            }
        }
        let mut bits = 0x1234_5678_9abc_def0_u64;
        for _ in 0..1_000_000 {
            bits = bits
                .wrapping_mul(6_364_136_223_846_793_005)
                .wrapping_add(1_442_695_040_888_963_407);
            let value = f64::from_bits(bits);
            if value.is_finite() {
                assert_eq!(round_half_even(value), previous(value), "{value}");
            }
        }
        assert_eq!(round_half_even(f64::NAN), 0);
        assert_eq!(round_half_even(f64::NEG_INFINITY), i64::MIN);
    }

    #[test]
    fn floor_div_matches_python() {
        assert_eq!(floor_div(7, 2), 3);
        assert_eq!(floor_div(-7, 2), -4);
        assert_eq!(floor_div(7, -2), -4);
        assert_eq!(floor_div(-7, -2), 3);
    }
}
