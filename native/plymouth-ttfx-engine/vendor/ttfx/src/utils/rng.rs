//! Engine RNG: xoshiro256++ with Python-`random`-shaped helpers.
//!
//! The helper semantics here are the parity contract: tools/parity/shim.py
//! implements the exact same algorithms in Python and monkeypatches the
//! `random` module with them, so both implementations draw identical
//! sequences given the same seed (plan.md §7). Do not change any helper's
//! algorithm without updating the shim in lockstep.

use super::rng_jump::{JUMP, JUMP_STEPS};

/// A batch is LANES runs of LANE consecutive draws.
const LANE: usize = 512;
const LANES: usize = 8;
/// Outputs generated per refill.
const BATCH: usize = LANES * LANE;
const _: () = assert!(JUMP_STEPS == (LANES - 1) * LANE);

/// The generator runs ahead in batches: a refill keeps the state in registers
/// for a whole batch, where a draw at a time would round-trip it through
/// memory. The sequence is the same.
///
/// With AVX-512 a batch is eight lanes of LANE consecutive draws generated
/// side by side. The state transition is linear over GF(2), so lane i's next
/// start - LANES - 1 lanes past its end - is a fixed 256x256 bit matrix
/// (JUMP) times its end state. The first batch runs scalar and records the
/// lanes' end states.
pub struct Rng {
    s: [u64; 4],
    /// The stream's state before `batch[0]`.
    start: [u64; 4],
    batch: Box<[u64; BATCH]>,
    /// Next unread output in `batch`.
    pos: usize,
    /// Every lane's end state after the last batch, word-major (lanes[w][i]
    /// is word w of lane i), once a batch has recorded them.
    lanes: Option<[[u64; LANES]; 4]>,
    avx512: bool,
}

impl Rng {
    pub fn seeded(seed: u64) -> Self {
        // SplitMix64 expansion of the seed into the xoshiro state, the
        // reference-recommended initialization.
        let mut sm = seed;
        let mut next = || {
            sm = sm.wrapping_add(0x9E3779B97F4A7C15);
            let mut z = sm;
            z = (z ^ (z >> 30)).wrapping_mul(0xBF58476D1CE4E5B9);
            z = (z ^ (z >> 27)).wrapping_mul(0x94D049BB133111EB);
            z ^ (z >> 31)
        };
        Rng::from_state([next(), next(), next(), next()])
    }

    pub fn from_entropy() -> Self {
        let mut buf = [0u8; 8];
        // /dev/urandom is always present on the Unix targets we support
        // (Linux and macOS).
        use std::io::Read;
        std::fs::File::open("/dev/urandom")
            .and_then(|mut f| f.read_exact(&mut buf))
            .expect("failed to read /dev/urandom");
        Rng::seeded(u64::from_le_bytes(buf))
    }

    /// The raw generator state, so another engine can continue the stream:
    /// the batch's start state stepped past the draws already read.
    pub fn state(&self) -> [u64; 4] {
        if self.pos == BATCH {
            return self.s;
        }
        let mut s = self.start;
        for _ in 0..self.pos {
            step(&mut s);
        }
        s
    }

    pub fn from_state(s: [u64; 4]) -> Self {
        Rng {
            s,
            start: s,
            batch: Box::new([0; BATCH]),
            pos: BATCH,
            lanes: None,
            avx512: avx512_available(),
        }
    }

    /// Core generator: xoshiro256++ next().
    #[inline]
    fn next_u64(&mut self) -> u64 {
        if self.pos == BATCH {
            self.refill();
        }
        let result = self.batch[self.pos];
        self.pos += 1;
        result
    }

    #[inline(never)]
    fn refill(&mut self) {
        self.start = self.s;
        match self.lanes {
            #[cfg(target_arch = "x86_64")]
            // SAFETY: `lanes` is only recorded when AVX-512F is available.
            Some(lanes) => unsafe { self.refill_lanes(lanes) },
            _ => self.refill_scalar(),
        }
        self.pos = 0;
    }

    fn refill_scalar(&mut self) {
        let [mut s0, mut s1, mut s2, mut s3] = self.s;
        let mut ends = [[0u64; LANES]; 4];
        for (lane, block) in self.batch.chunks_exact_mut(LANE).enumerate() {
            for out in block {
                *out = s0.wrapping_add(s3).rotate_left(23).wrapping_add(s0);
                let t = s1 << 17;
                s2 ^= s0;
                s3 ^= s1;
                s1 ^= s2;
                s0 ^= s3;
                s2 ^= t;
                s3 = s3.rotate_left(45);
            }
            for (w, word) in [s0, s1, s2, s3].into_iter().enumerate() {
                ends[w][lane] = word;
            }
        }
        self.s = [s0, s1, s2, s3];
        if self.avx512 {
            self.lanes = Some(ends);
        }
    }

    /// A batch of eight lanes side by side (see Rng).
    #[cfg(target_arch = "x86_64")]
    #[target_feature(enable = "avx512f")]
    fn refill_lanes(&mut self, ends: [[u64; LANES]; 4]) {
        use super::simd::{load_si512, store_si256, store_si512};
        use std::arch::x86_64::*;
        // the jump: each lane's start is the XOR of the rows of its end
        // state's set bits
        let mut s = [_mm512_setzero_si512(); 4];
        for w in 0..4 {
            let end = load_si512(&ends[w], 0);
            for b in 0..64 {
                let k = _mm512_test_epi64_mask(end, _mm512_set1_epi64(1 << b));
                let row = &JUMP[w * 64 + b];
                for (j, sj) in s.iter_mut().enumerate() {
                    *sj = _mm512_mask_xor_epi64(*sj, k, *sj, _mm512_set1_epi64(row[j] as i64));
                }
            }
        }
        let [mut s0, mut s1, mut s2, mut s3] = s;
        // LANE steps of all eight lanes, four at a time; a transpose turns the
        // four outputs (lane i in qword i) into four consecutive draws a lane
        let idx_lo = _mm512_setr_epi64(0, 1, 8, 9, 2, 3, 10, 11);
        let idx_hi = _mm512_setr_epi64(4, 5, 12, 13, 6, 7, 14, 15);
        for j in (0..LANE).step_by(4) {
            let mut out = [_mm512_setzero_si512(); 4];
            for o in &mut out {
                *o = _mm512_add_epi64(_mm512_rol_epi64::<23>(_mm512_add_epi64(s0, s3)), s0);
                let t = _mm512_slli_epi64::<17>(s1);
                let s3s1 = _mm512_xor_si512(s3, s1);
                s1 = _mm512_ternarylogic_epi64::<0x96>(s1, s2, s0); // s1 ^= s2 ^ s0
                s2 = _mm512_ternarylogic_epi64::<0x96>(s2, s0, t); // s2 ^= s0 ^ t
                s0 = _mm512_xor_si512(s0, s3s1); // s0 ^= s3 ^ s1
                s3 = _mm512_rol_epi64::<45>(s3s1);
            }
            let u0 = _mm512_unpacklo_epi64(out[0], out[1]); // even lanes: draws j, j+1
            let u1 = _mm512_unpackhi_epi64(out[0], out[1]); // odd lanes
            let u2 = _mm512_unpacklo_epi64(out[2], out[3]); // even lanes: j+2, j+3
            let u3 = _mm512_unpackhi_epi64(out[2], out[3]);
            let quads = [
                (_mm512_permutex2var_epi64(u0, idx_lo, u2), 0, 2),
                (_mm512_permutex2var_epi64(u0, idx_hi, u2), 4, 6),
                (_mm512_permutex2var_epi64(u1, idx_lo, u3), 1, 3),
                (_mm512_permutex2var_epi64(u1, idx_hi, u3), 5, 7),
            ];
            for (v, lo, hi) in quads {
                // lane blocks are LANE draws and j + 4 <= LANE
                store_si256(
                    &mut self.batch[..],
                    lo * LANE + j,
                    _mm512_castsi512_si256(v),
                );
                store_si256(
                    &mut self.batch[..],
                    hi * LANE + j,
                    _mm512_extracti64x4_epi64::<1>(v),
                );
            }
        }
        let mut lanes = [[0u64; LANES]; 4];
        for (w, v) in [s0, s1, s2, s3].into_iter().enumerate() {
            store_si512(&mut lanes[w], 0, v);
        }
        // lane 7's end is where the whole batch leaves the stream
        self.s = [lanes[0][7], lanes[1][7], lanes[2][7], lanes[3][7]];
        self.lanes = Some(lanes);
    }

    /// Python random.random() shape: float in [0, 1) with 53 bits of precision.
    pub fn random(&mut self) -> f64 {
        (self.next_u64() >> 11) as f64 * (1.0 / (1u64 << 53) as f64)
    }

    /// Uniform integer in [0, n) via Lemire-free simple rejection on bit masks —
    /// deterministic and trivially portable to the Python shim.
    #[inline]
    fn randbelow(&mut self, n: u64) -> u64 {
        assert!(n > 0, "randbelow(0)");
        let bits = 64 - (n - 1).leading_zeros();
        loop {
            let r = self.next_u64() >> (64 - bits.max(1));
            if r < n {
                return r;
            }
        }
    }

    /// randbelow(n) for every element of `out`, in order: the draws of that
    /// many choice_index(n) calls, with the batch cursor kept in a register.
    pub fn fill_below(&mut self, n: u64, out: &mut [u16]) {
        assert!(n > 0 && n <= 1 << 16, "fill_below({n})");
        let shift = 64 - (64 - (n - 1).leading_zeros()).max(1);
        // Branch-free rejection: every draw is stored and only an accepted
        // one advances the output, so the ~50% rejection rate of a typical n
        // costs no mispredictions.
        let len = out.len();
        let mut pos = self.pos;
        let mut k = 0;
        while k < len {
            // `>=`, not `==`: then pos < BATCH below is plain to the
            // compiler, and neither index is checked
            if pos >= BATCH {
                self.refill();
                pos = 0;
            }
            let r = self.batch[pos] >> shift;
            out[k] = r as u16;
            k += (r < n) as usize;
            pos += 1;
        }
        self.pos = pos;
    }

    /// fill_below alternating two bounds: `out[i]` is randbelow(`a`) for even
    /// i and randbelow(`b`) for odd i, drawn in order (the draws of that many
    /// alternating choice_index(a), choice_index(b) calls).
    pub fn fill_below_pairs(&mut self, a: u64, b: u64, out: &mut [u16]) {
        assert!(
            a > 0 && a <= 1 << 16 && b > 0 && b <= 1 << 16,
            "fill_below_pairs({a}, {b})"
        );
        let shift = |n: u64| 64 - (64 - (n - 1).leading_zeros()).max(1);
        let (sa, sb) = (shift(a), shift(b));
        // the bound and shift of the current draw, selected by mask so the
        // accept -> next draw chain stays a few ALU ops
        let (sx, nx) = (sa ^ sb, a ^ b);
        let len = out.len();
        let mut pos = self.pos;
        let mut k = 0;
        let mut odd = 0u64;
        while k < len {
            // as in fill_below: neither index is checked
            if pos >= BATCH {
                self.refill();
                pos = 0;
            }
            let mask = odd.wrapping_neg();
            let r = self.batch[pos] >> (sa ^ (sx & mask as u32));
            out[k] = r as u16;
            let accept = (r < (a ^ (nx & mask))) as u64;
            k += accept as usize;
            odd ^= accept;
            pos += 1;
        }
        self.pos = pos;
    }

    /// The unread draws of the current batch (refilled first when it is used
    /// up), for callers that scan ahead; `skip` then consumes the ones they
    /// used. The sequence is the same as drawing them one by one.
    #[inline]
    pub fn ahead(&mut self) -> &[u64] {
        if self.pos == BATCH {
            self.refill();
        }
        &self.batch[self.pos..]
    }

    /// Consume `n` draws of `ahead()`.
    #[inline]
    pub fn skip(&mut self, n: usize) {
        debug_assert!(self.pos + n <= BATCH);
        self.pos += n;
    }

    /// random.randint(a, b): inclusive both ends.
    #[inline]
    pub fn randint(&mut self, a: i64, b: i64) -> i64 {
        assert!(a <= b, "randint range empty: {a}..={b}");
        a + self.randbelow((b - a + 1) as u64) as i64
    }

    /// random.randrange(a, b): half-open.
    #[inline]
    pub fn randrange(&mut self, a: i64, b: i64) -> i64 {
        assert!(a < b, "randrange range empty: {a}..{b}");
        a + self.randbelow((b - a) as u64) as i64
    }

    /// random.choice(seq): seq[randbelow(len)].
    pub fn choice<'a, T>(&mut self, seq: &'a [T]) -> &'a T {
        assert!(!seq.is_empty(), "choice on empty sequence");
        &seq[self.randbelow(seq.len() as u64) as usize]
    }

    /// random.choice by index, for callers that need an owned element.
    #[inline]
    pub fn choice_index(&mut self, len: usize) -> usize {
        assert!(len > 0, "choice on empty sequence");
        self.randbelow(len as u64) as usize
    }

    /// random.uniform(a, b): a + (b-a) * random().
    pub fn uniform(&mut self, a: f64, b: f64) -> f64 {
        a + (b - a) * self.random()
    }

    /// random.shuffle: Fisher-Yates from the top, exactly CPython's loop
    /// (for i in reversed(range(1, len(x))): j = randbelow(i+1); swap).
    pub fn shuffle<T>(&mut self, seq: &mut [T]) {
        for i in (1..seq.len()).rev() {
            let j = self.randbelow((i + 1) as u64) as usize;
            seq.swap(i, j);
        }
    }
}

/// One xoshiro256++ state transition.
fn step(s: &mut [u64; 4]) {
    let t = s[1] << 17;
    s[2] ^= s[0];
    s[3] ^= s[1];
    s[1] ^= s[2];
    s[0] ^= s[3];
    s[2] ^= t;
    s[3] = s[3].rotate_left(45);
}

fn avx512_available() -> bool {
    #[cfg(target_arch = "x86_64")]
    {
        std::env::var_os("TTFX_NO_AVX512").is_none()
            && std::arch::is_x86_feature_detected!("avx512f")
    }
    #[cfg(not(target_arch = "x86_64"))]
    false
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn deterministic_for_seed() {
        let mut a = Rng::seeded(42);
        let mut b = Rng::seeded(42);
        for _ in 0..100 {
            assert_eq!(a.next_u64(), b.next_u64());
        }
    }

    fn scalar_step(s: &mut [u64; 4]) -> u64 {
        let result = s[0].wrapping_add(s[3]).rotate_left(23).wrapping_add(s[0]);
        let t = s[1] << 17;
        s[2] ^= s[0];
        s[3] ^= s[1];
        s[1] ^= s[2];
        s[0] ^= s[3];
        s[2] ^= t;
        s[3] = s[3].rotate_left(45);
        result
    }

    #[test]
    fn jump_matrix() {
        let mut s = [
            0x0123_4567_89ab_cdef,
            0xfedc_ba98_7654_3210,
            0x0f1e_2d3c_4b5a_6978,
            0x8796_a5b4_c3d2_e1f0,
        ];
        let mut jumped = [0u64; 4];
        for (w, word) in s.iter().enumerate() {
            for b in 0..64 {
                if word >> b & 1 != 0 {
                    for j in 0..4 {
                        jumped[j] ^= JUMP[w * 64 + b][j];
                    }
                }
            }
        }
        for _ in 0..JUMP_STEPS {
            scalar_step(&mut s);
        }
        assert_eq!(jumped, s);
    }

    #[test]
    fn batches_follow_the_stream() {
        // several batches, so the lane path (when available) runs too
        let mut rng = Rng::seeded(99);
        let mut s = Rng::seeded(99).s;
        for _ in 0..3 * BATCH + 17 {
            assert_eq!(rng.next_u64(), scalar_step(&mut s));
        }
    }

    #[test]
    fn fill_below_matches_choice_index() {
        for n in [1u64, 2, 3, 523, 1024, 65536] {
            let (mut a, mut b) = (Rng::seeded(n), Rng::seeded(n));
            for len in [0usize, 1, 63, 64, 65, 200] {
                let mut out = vec![0u16; len];
                a.fill_below(n, &mut out);
                let expected: Vec<u16> = (0..len)
                    .map(|_| b.choice_index(n as usize) as u16)
                    .collect();
                assert_eq!(out, expected);
            }
            assert_eq!(a.next_u64(), b.next_u64());
        }
    }

    #[test]
    fn fill_below_pairs_matches_choice_index() {
        for (x, y) in [(1u64, 1u64), (3, 25), (25, 3), (2, 65536), (523, 7)] {
            let (mut a, mut b) = (Rng::seeded(x * y), Rng::seeded(x * y));
            for len in [0usize, 1, 2, 63, 64, 65, 200] {
                let mut out = vec![0u16; len];
                a.fill_below_pairs(x, y, &mut out);
                let expected: Vec<u16> = (0..len)
                    .map(|i| b.choice_index(if i % 2 == 0 { x } else { y } as usize) as u16)
                    .collect();
                assert_eq!(out, expected);
                if len % 2 == 1 {
                    b.choice_index(y as usize);
                    a.choice_index(y as usize);
                }
            }
            assert_eq!(a.next_u64(), b.next_u64());
        }
    }

    #[test]
    fn ranges_respected() {
        let mut r = Rng::seeded(7);
        for _ in 0..1000 {
            let v = r.randint(-3, 3);
            assert!((-3..=3).contains(&v));
            let u = r.uniform(1.0, 2.0);
            assert!((1.0..2.0).contains(&u) || u == 2.0);
            assert!(r.random() < 1.0);
        }
    }
}
