//! Batched motion steps.
//!
//! update ticks the active set a bitmap word (64 slots) at a time. Before it
//! ticks a word, `motion_batch` works out the next step of every character
//! in it whose mirror (motion.rs) describes its active path, 8 lanes wide
//! with AVX-512 or 4 with AVX2, instead of one path walk per tick. For
//! parity each lane does `mirror_step`'s divide, multiplies and adds, with
//! no FMA, and cvtpd2dq's half-to-even rounding (a lane outside i32 converts
//! to i32::MIN and is left to the scalar step). Steps and distances go to the
//! mirrors at once (the old distances kept in `Batch`); coordinates wait in
//! `Batch` until update ticks the character (`motion_apply`).
//!
//! A step depends only on the character's own mirror, which only its own
//! tick changes - or an effect callback, or a change to a path another
//! character shares (which drops the mirror). So a result stands while the
//! mirror still describes the active path and no callback ran since the
//! batch (`motion_epoch`). Only a callback reads or changes another
//! character's path, so before one runs, the steps of the characters not
//! ticked yet are taken back (`motion_settle`). (A tick can also drop
//! another character's mirror when both are active on one path; no effect
//! shares an active path, and mirrors already assume none does.)
//!
//! Idle ticks. A step that neither moves the character nor ends the path is
//! unobservable, and so is step_animation for a character without a scene,
//! with no frames left, or with a synced, non-looping scene whose frame at
//! the new step is the one it shows. Those lanes come back in `idle`, and
//! update leaves them out of the word (a callback puts back the ones not
//! reached yet, `motion_settle`). The vector pass works out that frame index
//! with each step, for the sync key the slot last asked with
//! (`Mirrors::sync`); a batched tick that does more takes it too
//! (`take_sync_index`), sparing step_synced_scene its divides and the path
//! record.
//!
//! On aarch64 a NEON kernel takes the lanes two at a time (fcvtns for
//! cvtpd2dq, with NaN lanes left to the scalar step as well), and whether
//! update runs it is timed as it goes (`Adapt`). Below x86-64-v3 there is no
//! batch: every step goes through the scalar `mirror_step` or the walk.

use crate::utils::geometry::Coord;
use crate::utils::pycompat::round_half_even;

use super::motion::Mirrors;
use super::{At, Engine, Hooks, NONE};

/// A frame index motion_batch could not work out (cvtpd2dq's out of range).
pub(super) const NO_INDEX: u32 = 1 << 31;
/// A sync key's bit for a step-synced scene.
pub(super) const SYNC_KEY_STEP: u32 = 1 << 31;

/// A word's worked-out steps, by slot & 63.
pub struct Batch {
    step: [f64; 64],
    d: [f64; 64],
    /// The mirrors' distances before the batch (`restore`).
    old: [f64; 64],
    x: [i32; 64],
    y: [i32; 64],
    /// The synced scene's frame index at the step, for the slot's sync key
    /// (valid while `Mirrors::synced`; NO_INDEX when unknown).
    sidx: [u32; 64],
    /// The lanes whose tick does nothing but their step.
    pub(super) idle: u64,
    /// Quiet lanes with a scene: idle when the scene does nothing.
    quiet: u64,
    /// The lanes whose tick only moves a character without a scene.
    pub(super) bare: u64,
    /// The lanes of the word being ticked whose steps are in the mirrors.
    pub(super) live: u64,
    /// The slot whose tick takes its synced frame index from `sidx`, NONE.
    pub(super) hint: u32,
    /// The kernel the CPU runs: 0 none, 2 NEON, 3 AVX2, 4 AVX-512.
    tier: u8,
    /// Whether update runs the kernel.
    adapt: Adapt,
}

/// Whether update runs motion_batch. With the x86 kernels it always does.
/// The NEON kernel pays for itself only where enough ticks come back idle,
/// which depends on the effect and its phase, so the choice is timed: every
/// CYCLE updates the first PROBE run in pairs, one with the batch and the
/// next without, each pair a vote for the faster, and the winner runs the
/// rest of the cycle. (Votes, not summed times: a pair's two updates have
/// nearly the same work, and one slow outlier moves one vote.) The run's
/// first update, which pays for cold caches, is not timed. Either way the
/// output is the same. TTFX_NEON=on/off/flip (flip: switch every update, for
/// testing) overrides.
struct Adapt {
    policy: u8,
    on: bool,
    /// Updates into the cycle (CYCLE before the first update).
    n: u32,
    /// The pair's update with the batch took this many nanoseconds.
    with: u64,
    /// Pairs faster with the batch less those faster without.
    votes: i32,
}

const POLICY_OFF: u8 = 0;
const POLICY_ON: u8 = 1;
const POLICY_TIMED: u8 = 2;
const POLICY_FLIP: u8 = 3;
const CYCLE: u32 = 256;
const PROBE: u32 = 16;

impl Adapt {
    fn new(tier: u8) -> Self {
        let policy = match tier {
            0 => POLICY_OFF,
            2 => match std::env::var("TTFX_NEON").ok().as_deref() {
                Some("on") => POLICY_ON,
                Some("off") => POLICY_OFF,
                Some("flip") => POLICY_FLIP,
                _ => POLICY_TIMED,
            },
            _ => POLICY_ON,
        };
        Adapt {
            policy,
            on: policy != POLICY_OFF,
            n: CYCLE,
            with: 0,
            votes: 0,
        }
    }
}

impl Default for Batch {
    fn default() -> Self {
        let tier = tier();
        Batch {
            step: [0.0; 64],
            d: [0.0; 64],
            old: [0.0; 64],
            x: [0; 64],
            y: [0; 64],
            sidx: [NO_INDEX; 64],
            idle: 0,
            quiet: 0,
            bare: 0,
            live: 0,
            hint: NONE,
            tier,
            adapt: Adapt::new(tier),
        }
    }
}

/// step_synced_scene's frame index for `key` at (step, d) of a path with
/// (max_steps, total_distance), or NO_INDEX outside i32 (as cvtpd2dq).
#[inline(always)]
fn sync_index(key: u32, step: f64, max: f64, total: f64, d: f64) -> u32 {
    let last = (key & !SYNC_KEY_STEP) as i64 - 1;
    let ratio = if key & SYNC_KEY_STEP != 0 {
        step.max(1.0) / max.max(1.0)
    } else {
        let whole = total.max(1.0);
        let remaining = (total - d).max(1.0);
        (whole - remaining).max(1.0) / whole
    };
    let index = round_half_even(last as f64 * ratio);
    if index <= i32::MIN as i64 || index > i32::MAX as i64 {
        return NO_INDEX;
    }
    index.min(last).max(0) as u32
}

/// The widest kernel the CPU runs. TTFX_NO_AVX512 and TTFX_NO_AVX2 (for
/// testing) leave out the kernels that need them.
fn tier() -> u8 {
    #[cfg(target_arch = "x86_64")]
    {
        use std::arch::is_x86_feature_detected as has;
        let off = |name: &str| std::env::var_os(name).is_some();
        if off("TTFX_NO_AVX2") {
            return 0;
        }
        if !off("TTFX_NO_AVX512") && has!("avx512f") && has!("avx512vl") && has!("avx2") {
            return 4;
        }
        if has!("avx2") {
            return 3;
        }
    }
    #[cfg(target_arch = "aarch64")]
    if std::env::var_os("TTFX_NO_NEON").is_none() {
        return 2;
    }
    0
}

/// Lanes of `v` with every bit of `bits` set: all ones, else zero.
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx2")]
#[inline]
fn all_set4(
    v: std::arch::x86_64::__m256i,
    bits: std::arch::x86_64::__m256i,
) -> std::arch::x86_64::__m256i {
    use std::arch::x86_64::*;
    _mm256_cmpeq_epi64(_mm256_and_si256(v, bits), bits)
}

/// Bits 0-3 of `lanes` as a lane mask.
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx2")]
#[inline]
fn lane_mask4(lanes: u32) -> std::arch::x86_64::__m256i {
    use std::arch::x86_64::*;
    all_set4(
        _mm256_set1_epi64x(lanes as i64),
        _mm256_setr_epi64x(1, 2, 4, 8),
    )
}

/// The sign bits of four i32 lanes.
#[cfg(target_arch = "x86_64")]
#[target_feature(enable = "avx2")]
#[inline]
fn signs4(v: std::arch::x86_64::__m128i) -> u32 {
    use std::arch::x86_64::*;
    _mm_movemask_ps(_mm_castsi128_ps(v)) as u32
}

impl Batch {
    /// The scalar step of lane `k` (slot base + k); its bit when done.
    #[inline(always)]
    fn one(&mut self, m: &mut Mirrors, etab: &[f64], base: usize, k: usize) -> u64 {
        let slot = (base + k) as u32;
        if let Some(r) = m.next_step(etab, slot) {
            let (x, y) = (round_half_even(r.x), round_half_even(r.y));
            if (i32::MIN as i64) < x.min(y) && x.max(y) <= i32::MAX as i64 {
                self.step[k] = r.step;
                self.d[k] = r.d;
                self.old[k] = *m.last.at(slot);
                *m.step.at_mut(slot) = r.step;
                *m.last.at_mut(slot) = r.d;
                self.x[k] = x as i32;
                self.y[k] = y as i32;
                return 1 << k;
            }
        }
        0
    }

    /// Classify the step of lane `k` (done by `one`) as the kernels do.
    #[inline(always)]
    fn classify(&mut self, m: &Mirrors, coord: &[Coord], scene: &[u32], base: usize, k: usize) {
        let slot = (base + k) as u32;
        if m.synced {
            let (max, total) = (*m.max.at(slot), *m.total.at(slot));
            self.sidx[k] = sync_index(*m.sync.at(slot), self.step[k], max, total, self.d[k]);
        }
        if self.step[k] == *m.max.at(slot) {
            return;
        }
        let still = *coord.at(slot) == Coord::new(self.x[k] as i64, self.y[k] as i64);
        match (still, *scene.at(slot) == NONE) {
            (true, true) => self.idle |= 1 << k,
            (true, false) => self.quiet |= 1 << k,
            (false, true) => self.bare |= 1 << k,
            (false, false) => {}
        }
    }

    /// Take word `w`'s steps in `lanes` back out of their mirrors.
    pub(super) fn restore(&self, m: &mut Mirrors, w: usize, mut lanes: u64) {
        while lanes != 0 {
            let k = lanes.trailing_zeros() as usize;
            lanes &= lanes - 1;
            let slot = (w * 64 + k) as u32;
            // whole numbers below 2^53: exact
            *m.step.at_mut(slot) = self.step[k] - 1.0;
            *m.last.at_mut(slot) = self.old[k];
        }
    }

    /// Whether this update runs the batch, and whether it is timed for
    /// `timed` (see Adapt).
    #[inline(always)]
    pub(super) fn plan(&mut self) -> (bool, bool) {
        let a = &mut self.adapt;
        match a.policy {
            POLICY_OFF => (false, false),
            POLICY_ON => (true, false),
            POLICY_FLIP => {
                a.on = !a.on;
                (a.on, false)
            }
            _ => {
                let n = a.n;
                a.n = if n + 1 >= CYCLE { 0 } else { n + 1 };
                if n < PROBE {
                    return (n & 1 == 0, true);
                }
                if n == PROBE {
                    a.on = a.votes >= 0;
                    a.votes = 0;
                }
                (a.on, false)
            }
        }
    }

    /// A probing update took `nanos`.
    #[inline(always)]
    pub(super) fn timed(&mut self, on: bool, nanos: u64) {
        let a = &mut self.adapt;
        if on {
            a.with = nanos;
        } else {
            a.votes += if a.with <= nanos { 1 } else { -1 };
        }
    }

    /// The synced frame index motion_batch worked out for this tick of
    /// `slot`, if it is the tick the batch was for; NO_INDEX otherwise.
    #[inline(always)]
    pub(super) fn take_sync_index(&mut self, slot: u32) -> u32 {
        if self.hint != slot {
            return NO_INDEX;
        }
        self.hint = NONE;
        self.sidx[(slot & 63) as usize]
    }
}

impl Engine {
    /// Work out the steps of the word `w`'s characters in `snapshot` whose
    /// mirror describes their active path; returns the bits of the ones
    /// done (0 without AVX2).
    #[inline]
    pub(super) fn motion_batch(&mut self, w: usize, snapshot: u64) -> u64 {
        self.batch.idle = 0;
        self.batch.quiet = 0;
        self.batch.bare = 0;
        let done = match self.batch.tier {
            // SAFETY: the CPU supports these (checked when Batch was made).
            #[cfg(target_arch = "x86_64")]
            4 => unsafe { self.motion_batch_avx512(w, snapshot) },
            // SAFETY: as above.
            #[cfg(target_arch = "x86_64")]
            3 => unsafe { self.motion_batch_avx2(w, snapshot) },
            // SAFETY: NEON is baseline on aarch64.
            #[cfg(target_arch = "aarch64")]
            2 => unsafe { self.motion_batch_neon(w, snapshot) },
            _ => return 0,
        };
        let mut quiet = self.batch.quiet;
        while quiet != 0 {
            let k = quiet.trailing_zeros() as usize;
            quiet &= quiet - 1;
            let slot = (w * 64 + k) as u32;
            if self.animation_idle(slot, *self.ch.scene.at(slot), self.batch.sidx[k]) {
                self.batch.idle |= 1 << k;
            }
        }
        done
    }

    /// motion_batch_avx2 two lanes at a time with NEON. There is no gather
    /// (the eased lanes are loads) and fcvtns rounds as cvtpd2dq; lanes that
    /// round outside i32, or to i32::MIN, or are NaN are left to the scalar
    /// step. Kept out of update, whose tick loop it would crowd.
    #[cfg(target_arch = "aarch64")]
    #[target_feature(enable = "neon")]
    #[inline(never)]
    fn motion_batch_neon(&mut self, w: usize, snapshot: u64) -> u64 {
        use super::motion::{MF_CLAMP, MF_CURVE, MF_LOWER, MF_OVER};
        use crate::utils::simd::{
            bits_u64x2 as bits, lane_mask2, load, load_f64x2, load_split_s64x2, load_u32x2,
            store_f64x2, store_u32x2, widen_mask2,
        };
        use std::arch::aarch64::*;

        let (m, etab) = self.paths.mirrors_etab();
        let (ch_path, ch_coord, ch_scene) =
            (&self.ch.path[..], &self.ch.coord[..], &self.ch.scene[..]);
        assert!(ch_coord.len() == ch_path.len() && ch_scene.len() == ch_path.len());
        let b = &mut self.batch;
        let (mut done, mut idle, mut quiet, mut bare) = (0u64, 0u64, 0u64, 0u64);
        let base = w * 64;
        // every pair lies inside the mirror arrays (whole words long) and
        // inside ch.path, ch.coord and ch.scene (checked)
        let one = vdupq_n_f64(1.0);
        let zero = vdupq_n_f64(0.0);
        let none = vdup_n_u32(NONE);
        let int_min = vdupq_n_s64(i32::MIN as i64);
        let int_max = vdupq_n_s64(i32::MAX as i64);
        // x rounds (to r) inside i32 above i32::MIN, and is not NaN
        let fits = |x: float64x2_t, r: int64x2_t| {
            vandq_u64(
                vceqq_f64(x, x),
                vandq_u64(vcgtq_s64(r, int_min), vcleq_s64(r, int_max)),
            )
        };
        let mut pairs = snapshot;
        while pairs != 0 {
            let k = pairs.trailing_zeros() as usize & !1;
            let lanes = (pairs >> k) as u32 & 3;
            pairs &= !(3u64 << k);
            let s = base + k;
            if s + 2 > ch_path.len() {
                // the last character: the scalar step
                if lanes & 1 != 0 && m.path[s] != NONE && m.path[s] == ch_path[s] {
                    let bit = b.one(m, etab, base, k);
                    if bit != 0 {
                        b.classify(m, ch_coord, ch_scene, base, k);
                    }
                    done |= bit;
                }
                continue;
            }
            let mp = load_u32x2(&m.path, s);
            let mirrored = vbic_u32(vceq_u32(mp, load_u32x2(ch_path, s)), vceq_u32(mp, none));
            let lanes = lanes & bits(widen_mask2(mirrored));
            if lanes == 0 {
                continue;
            }
            let live = lane_mask2(lanes);
            let step = vaddq_f64(load_f64x2(&m.step, s), one);
            let max = load_f64x2(&m.max, s);
            let valid = vcleq_f64(step, max);
            let tab: [u32; 2] = load(&m.etab, s);
            let linear = widen_mask2(vceqz_u32(load_u32x2(&m.etab, s)));
            let ratio = vdivq_f64(step, max);
            let gather = bits(vbicq_u64(vandq_u64(valid, live), linear));
            let factor = if gather == 0 {
                ratio
            } else {
                // the eased lanes' factors (the table runs past the step:
                // step <= max_steps)
                let mut eased = [0.0; 2];
                for j in 0..2 {
                    if gather >> j & 1 != 0 {
                        eased[j] = etab[tab[j] as usize + (m.step[s + j] + 1.0) as usize];
                    }
                }
                vbslq_f64(linear, ratio, load_f64x2(&eased, 0))
            };
            let total = load_f64x2(&m.total, s);
            let d = vmulq_f64(factor, total);
            let off = load_f64x2(&m.off, s);
            let hi = load_f64x2(&m.hi, s);
            let [f0, f1]: [u8; 2] = load(&m.flags, s);
            let flags = vcombine_u64(vcreate_u64(f0 as u64), vcreate_u64(f1 as u64));
            let flag = |bit: u8| vtstq_u64(flags, vdupq_n_u64(bit as u64));
            let (lower, curve, clamp, over) = (
                flag(MF_LOWER),
                flag(MF_CURVE),
                flag(MF_CLAMP),
                flag(MF_OVER),
            );
            let r = vsubq_f64(d, off);
            let within = vorrq_u64(vcleq_f64(r, hi), over);
            let r = vbslq_f64(over, vaddq_f64(r, hi), r);
            let above = vorrq_u64(
                vreinterpretq_u64_u32(vmvnq_u32(vreinterpretq_u32_u64(lower))),
                vcgtq_f64(d, off),
            );
            let ok = vandq_u64(vandq_u64(valid, within), above);
            // t = r / hi (0 for an empty segment; a linear ratio at most
            // 1.0, and fminnm picks 1.0 over NaN as f64::min does)
            let q = vdivq_f64(r, hi);
            let t = vbslq_f64(clamp, vminnmq_f64(q, one), q);
            let t = vbslq_f64(vceqq_f64(hi, zero), zero, t);
            let u = vsubq_f64(one, t);
            let lerp = |a: float64x2_t, b: float64x2_t| vaddq_f64(vmulq_f64(u, a), vmulq_f64(t, b));
            // a line's control is its end: one lerp unless a lane curves
            let curves = bits(vandq_u64(curve, live)) != 0;
            let point = |start: &[f64], control: &[f64], end: &[f64]| {
                let (a, e) = (load_f64x2(start, s), load_f64x2(end, s));
                let line = lerp(a, e);
                if !curves {
                    return line;
                }
                let c = load_f64x2(control, s);
                vbslq_f64(curve, lerp(lerp(a, c), lerp(c, e)), line)
            };
            let (x, y) = (point(&m.sx, &m.cx, &m.ex), point(&m.sy, &m.cy, &m.ey));
            let (xi, yi) = (vcvtnq_s64_f64(x), vcvtnq_s64_f64(y));
            let taken = vandq_u64(vandq_u64(ok, live), vandq_u64(fits(x, xi), fits(y, yi)));
            let lanes = bits(taken);
            store_f64x2(&mut b.step, k, step);
            store_f64x2(&mut b.d, k, d);
            let last = load_f64x2(&m.last, s);
            store_f64x2(&mut b.old, k, last);
            let kept = load_f64x2(&m.step, s);
            store_f64x2(&mut m.step, s, vbslq_f64(taken, step, kept));
            store_f64x2(&mut m.last, s, vbslq_f64(taken, d, last));
            store_u32x2(&mut b.x, k, vreinterpret_u32_s32(vmovn_s64(xi)));
            store_u32x2(&mut b.y, k, vreinterpret_u32_s32(vmovn_s64(yi)));
            done |= (lanes as u64) << k;
            let c = load_split_s64x2(ch_coord, s);
            let same = bits(vandq_u64(vceqq_s64(c.0, xi), vceqq_s64(c.1, yi)));
            let on = lanes & !bits(vceqq_f64(step, max));
            let no_scene = bits(widen_mask2(vceq_u32(load_u32x2(ch_scene, s), none)));
            idle |= ((on & same & no_scene) as u64) << k;
            quiet |= ((on & same & !no_scene) as u64) << k;
            bare |= ((on & !same & no_scene) as u64) << k;
            if m.synced {
                // step_synced_scene's frame index at the new step
                let key = vreinterpret_s32_u32(load_u32x2(&m.sync, s));
                let by_step = vcltzq_s64(vmovl_s32(key));
                let ratio_step = vdivq_f64(vmaxnmq_f64(step, one), vmaxnmq_f64(max, one));
                let whole = vmaxnmq_f64(total, one);
                let remaining = vmaxnmq_f64(vsubq_f64(total, d), one);
                let ratio_d = vdivq_f64(vmaxnmq_f64(vsubq_f64(whole, remaining), one), whole);
                let ratio = vbslq_f64(by_step, ratio_step, ratio_d);
                let last = vmovl_s32(vsub_s32(vand_s32(key, vdup_n_s32(i32::MAX)), vdup_n_s32(1)));
                let f = vmulq_f64(vcvtq_f64_s64(last), ratio);
                let index = vcvtnq_s64_f64(f);
                let known = fits(f, index);
                let index = vbslq_s64(vcltq_s64(index, last), index, last);
                let index = vbslq_s64(vcgtzq_s64(index), index, vdupq_n_s64(0));
                let index = vbslq_s64(known, index, int_min);
                store_u32x2(&mut b.sidx, k, vreinterpret_u32_s32(vmovn_s64(index)));
            }
        }
        b.idle = idle;
        b.quiet = quiet;
        b.bare = bare;
        done
    }

    #[cfg(target_arch = "x86_64")]
    #[target_feature(enable = "avx2")]
    fn motion_batch_avx2(&mut self, w: usize, snapshot: u64) -> u64 {
        use super::motion::{MF_CLAMP, MF_CURVE, MF_LOWER, MF_OVER};
        use crate::utils::simd::{
            load, load2_si256, load_pd, load_si128, maskstore_pd, store_pd, store_si128,
        };
        use std::arch::x86_64::*;

        let (m, etab) = self.paths.mirrors_etab();
        let (ch_path, ch_coord, ch_scene) =
            (&self.ch.path[..], &self.ch.coord[..], &self.ch.scene[..]);
        assert!(ch_coord.len() == ch_path.len() && ch_scene.len() == ch_path.len());
        let b = &mut self.batch;
        let mut done = 0u64;
        let base = w * 64;
        // every group lies inside the mirror arrays (sized to whole groups of
        // 8 past every slot) and inside ch.path, ch.coord and ch.scene
        // (checked)
        let one = _mm256_set1_pd(1.0);
        let zero = _mm256_setzero_pd();
        let none = _mm_set1_epi32(NONE as i32);
        let int_min = _mm_set1_epi32(i32::MIN);
        let mut groups = snapshot;
        while groups != 0 {
            let g = groups.trailing_zeros() as usize / 4;
            let lanes = (groups >> (g * 4)) as u32 & 0xf;
            groups &= !(0xfu64 << (g * 4));
            let s = base + g * 4;
            if s + 4 > ch_path.len() {
                continue;
            }
            debug_assert!(s + 4 <= m.path.len());
            let mp = load_si128(&m.path, s);
            let cp = load_si128(ch_path, s);
            let mirrored = _mm_andnot_si128(_mm_cmpeq_epi32(mp, none), _mm_cmpeq_epi32(mp, cp));
            let lanes = lanes & signs4(mirrored);
            if lanes == 0 {
                continue;
            }
            if lanes & (lanes - 1) == 0 {
                // one lane: the scalar step is cheaper
                let k = g * 4 + lanes.trailing_zeros() as usize;
                let bit = b.one(m, etab, base, k);
                if bit != 0 {
                    b.classify(m, ch_coord, ch_scene, base, k);
                }
                done |= bit;
                continue;
            }
            let step = _mm256_add_pd(load_pd(&m.step, s), one);
            let max = load_pd(&m.max, s);
            let valid = _mm256_cmp_pd::<_CMP_LE_OQ>(step, max);
            let tab = load_si128(&m.etab, s);
            let linear = _mm256_castsi256_pd(_mm256_cvtepi32_epi64(_mm_cmpeq_epi32(
                tab,
                _mm_setzero_si128(),
            )));
            let live = _mm256_castsi256_pd(lane_mask4(lanes));
            let gather = _mm256_and_pd(_mm256_andnot_pd(linear, valid), live);
            let ratio = _mm256_div_pd(step, max);
            let factor = if _mm256_movemask_pd(gather) == 0 {
                ratio
            } else {
                let index = _mm_add_epi32(tab, _mm256_cvttpd_epi32(step));
                // SAFETY: the gather reads etab only at lanes whose mirror
                // names a table offset whose entries run past the step
                // (step <= max_steps).
                let eased =
                    unsafe { _mm256_mask_i32gather_pd::<8>(zero, etab.as_ptr(), index, gather) };
                _mm256_blendv_pd(eased, ratio, linear)
            };
            let total = load_pd(&m.total, s);
            let d = _mm256_mul_pd(factor, total);
            let off = load_pd(&m.off, s);
            let hi = load_pd(&m.hi, s);
            let flags =
                _mm256_cvtepu8_epi64(_mm_cvtsi32_si128(i32::from_ne_bytes(load(&m.flags, s))));
            let flag =
                |bit: u8| _mm256_castsi256_pd(all_set4(flags, _mm256_set1_epi64x(bit as i64)));
            let (lower, curve, clamp, over) = (
                flag(MF_LOWER),
                flag(MF_CURVE),
                flag(MF_CLAMP),
                flag(MF_OVER),
            );
            let r = _mm256_sub_pd(d, off);
            let within = _mm256_or_pd(_mm256_cmp_pd::<_CMP_LE_OQ>(r, hi), over);
            let r = _mm256_blendv_pd(r, _mm256_add_pd(r, hi), over);
            let above = _mm256_or_pd(
                _mm256_andnot_pd(lower, _mm256_castsi256_pd(_mm256_set1_epi64x(-1))),
                _mm256_cmp_pd::<_CMP_GT_OQ>(d, off),
            );
            let ok = _mm256_and_pd(_mm256_and_pd(valid, within), above);
            // t = r / hi (0 for an empty segment; a linear ratio at most
            // 1.0, and min picks 1.0 over NaN as f64::min does)
            let q = _mm256_div_pd(r, hi);
            let t = _mm256_blendv_pd(q, _mm256_min_pd(q, one), clamp);
            let t = _mm256_andnot_pd(_mm256_cmp_pd::<_CMP_EQ_OQ>(hi, zero), t);
            let u = _mm256_sub_pd(one, t);
            let lerp =
                |a: __m256d, b: __m256d| _mm256_add_pd(_mm256_mul_pd(u, a), _mm256_mul_pd(t, b));
            // a line's control is its end: one lerp unless a lane curves
            let curves = _mm256_movemask_pd(_mm256_and_pd(curve, live)) != 0;
            let point = |start: &[f64], control: &[f64], end: &[f64]| {
                let (a, e) = (load_pd(start, s), load_pd(end, s));
                let line = lerp(a, e);
                if !curves {
                    return _mm256_cvtpd_epi32(line);
                }
                let c = load_pd(control, s);
                let bent = lerp(lerp(a, c), lerp(c, e));
                _mm256_cvtpd_epi32(_mm256_blendv_pd(line, bent, curve))
            };
            let x = point(&m.sx, &m.cx, &m.ex);
            let y = point(&m.sy, &m.cy, &m.ey);
            let wide = _mm_or_si128(_mm_cmpeq_epi32(x, int_min), _mm_cmpeq_epi32(y, int_min));
            let lanes = lanes & _mm256_movemask_pd(ok) as u32 & !signs4(wide);
            let k = g * 4;
            store_pd(&mut b.step, k, step);
            store_pd(&mut b.d, k, d);
            let taken = lane_mask4(lanes);
            store_pd(&mut b.old, k, load_pd(&m.last, s));
            maskstore_pd(&mut m.step, s, taken, step);
            maskstore_pd(&mut m.last, s, taken, d);
            store_si128(&mut b.x, k, x);
            store_si128(&mut b.y, k, y);
            done |= (lanes as u64) << k;
            let [c0, c1] = load2_si256(ch_coord, s);
            let cols = _mm256_permute4x64_epi64::<0xd8>(_mm256_unpacklo_epi64(c0, c1));
            let rows = _mm256_permute4x64_epi64::<0xd8>(_mm256_unpackhi_epi64(c0, c1));
            let same = _mm256_and_si256(
                _mm256_cmpeq_epi64(cols, _mm256_cvtepi32_epi64(x)),
                _mm256_cmpeq_epi64(rows, _mm256_cvtepi32_epi64(y)),
            );
            let same = _mm256_movemask_pd(_mm256_castsi256_pd(same)) as u32;
            let on = lanes & _mm256_movemask_pd(_mm256_cmp_pd::<_CMP_NEQ_UQ>(step, max)) as u32;
            let bare = signs4(_mm_cmpeq_epi32(load_si128(ch_scene, s), none));
            b.idle |= ((on & same & bare) as u64) << k;
            b.quiet |= ((on & same & !bare) as u64) << k;
            b.bare |= ((on & !same & bare) as u64) << k;
            if m.synced {
                // step_synced_scene's frame index at the new step
                let key = load_si128(&m.sync, s);
                let by_step = _mm256_castsi256_pd(_mm256_cvtepi32_epi64(key));
                let ratio_step = _mm256_div_pd(_mm256_max_pd(step, one), _mm256_max_pd(max, one));
                let whole = _mm256_max_pd(total, one);
                let remaining = _mm256_max_pd(_mm256_sub_pd(total, d), one);
                let ratio_d =
                    _mm256_div_pd(_mm256_max_pd(_mm256_sub_pd(whole, remaining), one), whole);
                let ratio = _mm256_blendv_pd(ratio_d, ratio_step, by_step);
                let last = _mm_sub_epi32(
                    _mm_and_si128(key, _mm_set1_epi32(i32::MAX)),
                    _mm_set1_epi32(1),
                );
                let index = _mm256_cvtpd_epi32(_mm256_mul_pd(_mm256_cvtepi32_pd(last), ratio));
                let unknown = _mm_cmpeq_epi32(index, int_min);
                let index = _mm_max_epi32(_mm_min_epi32(index, last), _mm_setzero_si128());
                let index = _mm_blendv_epi8(index, int_min, unknown);
                store_si128(&mut b.sidx, k, index);
            }
        }
        done
    }

    #[cfg(target_arch = "x86_64")]
    #[target_feature(enable = "avx512f,avx512vl,avx2")]
    fn motion_batch_avx512(&mut self, w: usize, snapshot: u64) -> u64 {
        use super::motion::{MF_CLAMP, MF_CURVE, MF_LOWER, MF_OVER};
        use crate::utils::simd::{
            load, load2_si512, load_pd8, load_si256, mask_store_pd8, store_pd8, store_si256,
        };
        use std::arch::x86_64::*;

        let (m, etab) = self.paths.mirrors_etab();
        let (ch_path, ch_coord, ch_scene) =
            (&self.ch.path[..], &self.ch.coord[..], &self.ch.scene[..]);
        assert!(ch_coord.len() == ch_path.len() && ch_scene.len() == ch_path.len());
        let b = &mut self.batch;
        let mut done = 0u64;
        let base = w * 64;
        // as for motion_batch_avx2, with groups of 8 (the mirror arrays are
        // whole words long)
        let one = _mm512_set1_pd(1.0);
        let zero = _mm512_setzero_pd();
        let none = _mm256_set1_epi32(NONE as i32);
        let int_min = _mm256_set1_epi32(i32::MIN);
        let mut groups = snapshot;
        while groups != 0 {
            let g = groups.trailing_zeros() as usize / 8;
            let lanes = (groups >> (g * 8)) as u8;
            groups &= !(0xffu64 << (g * 8));
            let s = base + g * 8;
            if s + 8 > ch_path.len() {
                let mut l = lanes;
                while l != 0 {
                    let k = g * 8 + l.trailing_zeros() as usize;
                    l &= l - 1;
                    if base + k < ch_path.len()
                        && m.path[base + k] != NONE
                        && m.path[base + k] == ch_path[base + k]
                    {
                        let bit = b.one(m, etab, base, k);
                        if bit != 0 {
                            b.classify(m, ch_coord, ch_scene, base, k);
                        }
                        done |= bit;
                    }
                }
                continue;
            }
            debug_assert!(s + 8 <= m.path.len());
            let mp = load_si256(&m.path, s);
            let cp = load_si256(ch_path, s);
            let lanes =
                lanes & _mm256_cmpeq_epi32_mask(mp, cp) & _mm256_cmpneq_epi32_mask(mp, none);
            if lanes == 0 {
                continue;
            }
            if lanes & (lanes - 1) == 0 {
                let k = g * 8 + lanes.trailing_zeros() as usize;
                let bit = b.one(m, etab, base, k);
                if bit != 0 {
                    b.classify(m, ch_coord, ch_scene, base, k);
                }
                done |= bit;
                continue;
            }
            let step = _mm512_add_pd(load_pd8(&m.step, s), one);
            let max = load_pd8(&m.max, s);
            let valid = _mm512_cmp_pd_mask::<_CMP_LE_OQ>(step, max);
            let tab = load_si256(&m.etab, s);
            let linear = _mm256_cmpeq_epi32_mask(tab, _mm256_setzero_si256());
            let ratio = _mm512_div_pd(step, max);
            let gather = !linear & valid & lanes;
            let factor = if gather == 0 {
                ratio
            } else {
                let index = _mm256_add_epi32(tab, _mm512_cvttpd_epi32(step));
                // SAFETY: as for motion_batch_avx2.
                let eased =
                    unsafe { _mm512_mask_i32gather_pd::<8>(zero, gather, index, etab.as_ptr()) };
                _mm512_mask_blend_pd(linear, eased, ratio)
            };
            let total = load_pd8(&m.total, s);
            let d = _mm512_mul_pd(factor, total);
            let off = load_pd8(&m.off, s);
            let hi = load_pd8(&m.hi, s);
            let flags =
                _mm512_cvtepu8_epi64(_mm_cvtsi64_si128(i64::from_ne_bytes(load(&m.flags, s))));
            let flag = |bit: u8| _mm512_test_epi64_mask(flags, _mm512_set1_epi64(bit as i64));
            let (lower, curve, clamp, over) = (
                flag(MF_LOWER),
                flag(MF_CURVE),
                flag(MF_CLAMP),
                flag(MF_OVER),
            );
            let r = _mm512_sub_pd(d, off);
            let within = _mm512_cmp_pd_mask::<_CMP_LE_OQ>(r, hi) | over;
            let r = _mm512_mask_add_pd(r, over, r, hi);
            let above = !lower | _mm512_cmp_pd_mask::<_CMP_GT_OQ>(d, off);
            let ok = valid & within & above;
            // t = r / hi (0 for an empty segment; a linear ratio at most
            // 1.0, and min picks 1.0 over NaN as f64::min does)
            let q = _mm512_div_pd(r, hi);
            let t = _mm512_mask_blend_pd(clamp, q, _mm512_min_pd(q, one));
            let t = _mm512_mask_blend_pd(_mm512_cmp_pd_mask::<_CMP_EQ_OQ>(hi, zero), t, zero);
            let u = _mm512_sub_pd(one, t);
            let lerp =
                |a: __m512d, b: __m512d| _mm512_add_pd(_mm512_mul_pd(u, a), _mm512_mul_pd(t, b));
            let curves = curve & lanes != 0;
            let point = |start: &[f64], control: &[f64], end: &[f64]| {
                let (a, e) = (load_pd8(start, s), load_pd8(end, s));
                let line = lerp(a, e);
                if !curves {
                    return _mm512_cvtpd_epi32(line);
                }
                let c = load_pd8(control, s);
                let bent = lerp(lerp(a, c), lerp(c, e));
                _mm512_cvtpd_epi32(_mm512_mask_blend_pd(curve, line, bent))
            };
            let x = point(&m.sx, &m.cx, &m.ex);
            let y = point(&m.sy, &m.cy, &m.ey);
            let wide = _mm256_cmpeq_epi32_mask(x, int_min) | _mm256_cmpeq_epi32_mask(y, int_min);
            let lanes = lanes & ok & !wide;
            let k = g * 8;
            store_pd8(&mut b.step, k, step);
            store_pd8(&mut b.d, k, d);
            store_pd8(&mut b.old, k, load_pd8(&m.last, s));
            mask_store_pd8(&mut m.step, s, lanes, step);
            mask_store_pd8(&mut m.last, s, lanes, d);
            store_si256(&mut b.x, k, x);
            store_si256(&mut b.y, k, y);
            done |= (lanes as u64) << k;
            let [c0, c1] = load2_si512(ch_coord, s);
            let cols =
                _mm512_permutex2var_epi64(c0, _mm512_setr_epi64(0, 2, 4, 6, 8, 10, 12, 14), c1);
            let rows =
                _mm512_permutex2var_epi64(c0, _mm512_setr_epi64(1, 3, 5, 7, 9, 11, 13, 15), c1);
            let same = _mm512_cmpeq_epi64_mask(cols, _mm512_cvtepi32_epi64(x))
                & _mm512_cmpeq_epi64_mask(rows, _mm512_cvtepi32_epi64(y));
            let on = lanes & _mm512_cmp_pd_mask::<_CMP_NEQ_UQ>(step, max);
            let bare = _mm256_cmpeq_epi32_mask(load_si256(ch_scene, s), none);
            b.idle |= ((on & same & bare) as u64) << k;
            b.quiet |= ((on & same & !bare) as u64) << k;
            b.bare |= ((on & !same & bare) as u64) << k;
            if m.synced {
                let key = load_si256(&m.sync, s);
                let by_step = _mm256_cmplt_epi32_mask(key, _mm256_setzero_si256());
                let ratio_step = _mm512_div_pd(_mm512_max_pd(step, one), _mm512_max_pd(max, one));
                let whole = _mm512_max_pd(total, one);
                let remaining = _mm512_max_pd(_mm512_sub_pd(total, d), one);
                let ratio_d =
                    _mm512_div_pd(_mm512_max_pd(_mm512_sub_pd(whole, remaining), one), whole);
                let ratio = _mm512_mask_blend_pd(by_step, ratio_d, ratio_step);
                let last = _mm256_sub_epi32(
                    _mm256_and_si256(key, _mm256_set1_epi32(i32::MAX)),
                    _mm256_set1_epi32(1),
                );
                let index = _mm512_cvtpd_epi32(_mm512_mul_pd(_mm512_cvtepi32_pd(last), ratio));
                let unknown = _mm256_cmpeq_epi32_mask(index, int_min);
                let index = _mm256_max_epi32(_mm256_min_epi32(index, last), _mm256_setzero_si256());
                let index = _mm256_mask_mov_epi32(index, unknown, int_min);
                store_si256(&mut b.sidx, k, index);
            }
        }
        done
    }

    /// Motion.move for a character `motion_batch` stepped (the mirror has the
    /// step): the new coordinate, then the rest of Motion.move at max_steps.
    #[inline(always)]
    pub(super) fn motion_apply(&mut self, hooks: &mut dyn Hooks, slot: u32) {
        let lane = (slot & 63) as usize;
        let b = &self.batch;
        let (step, coord) = (b.step[lane], Coord::new(b.x[lane] as i64, b.y[lane] as i64));
        let reached = step == *self.paths.m.max.at(slot);
        if *self.ch.coord.at(slot) != coord {
            self.set_coordinate(slot, coord);
        }
        if reached {
            // the tail reads the record
            self.paths.release(slot);
            self.motion_tail(hooks, slot);
        } else {
            // the path goes on: this tick's synced frame index stands
            self.batch.hint = slot;
        }
    }

    /// A bare move (`Batch::bare`): the new coordinate (the mirror has the
    /// step), and nothing else happens on this tick.
    #[inline(always)]
    pub(super) fn bare_move(&mut self, slot: u32) {
        let lane = (slot & 63) as usize;
        let b = &self.batch;
        self.set_coordinate(slot, Coord::new(b.x[lane] as i64, b.y[lane] as i64));
    }

    /// The batch's result for this slot still stands: its mirror describes
    /// its active path and no callback ran since the batch.
    #[inline(always)]
    pub(super) fn batched(&self, slot: u32, epoch: u32) -> bool {
        let path = *self.paths.m.path.at(slot);
        self.motion_epoch == epoch && path != NONE && path == *self.ch.path.at(slot)
    }
}
