//! The active set, EffectCharacter.tick and BaseEffectIterator.update
//! (engine/ctx.rs, engine/active_characters.rs).
//!
//! The active set is a bitmap over slots, so iterating it visits characters
//! in ascending slot order, the canonical order parity demands. update ticks
//! a snapshot, then prunes. Only candidates can have left the set:
//! characters inserted since the last prune and characters whose scene or
//! path ended or was deactivated (every such engine path calls
//! `mark_candidate`). Pruning those equals the old engine's retain over the
//! whole set. The passes visit only the bitmap words `[lo, hi)`, which
//! `active_insert` widens and each prune narrows.
//!
//! Dozing. Most ticks only count down: no path, the visual unchanged, no
//! event - a plain scene's head frame ticking (and retiring, but for the
//! last frame), or an eased scene's steps that keep showing the same frame.
//! On update's tick, step_animation counts the pure ticks ahead (k) and
//! advances the scene's counter (ticks, or the eased step) past them at
//! once; `doze_try` sets the doze bit, keeping the character out of the
//! snapshots, and `wake[slot]`, the update number (mod 256) whose snapshot
//! takes it back. A doze may end on its head frame's last tick; that
//! retirement happens when it wakes (`doze_retire`).
//!
//! Anything that could make one of those ticks impure, or that reads or
//! rewrites the active scene's playback state, first calls `doze_wake`:
//! scene activation and deactivation, step_animation, set_appearance,
//! scene_reset, scene_new over a used record, active_remove, active_clear.
//! `doze_wake` gives back the ticks not yet due, and a character woken
//! during update ahead of the ticking slot rejoins this update's snapshot,
//! so it ticks exactly where the old engine ticks it.

use super::scene::SCF_EASED;
use super::{At, Engine, Hooks, NONE};

/// The longest doze: the wake byte must stay unambiguous.
const DOZE_MAX: u32 = 254;

pub struct Active {
    pub bits: Vec<u64>,
    snapshot: Vec<u64>,
    candidate: Vec<u64>,
    doze: Vec<u64>,
    /// Per slot, padded to whole words: the update (mod 256) whose snapshot
    /// takes a dozer back.
    wake: Vec<u8>,
    /// Words [lo, hi) hold every active character (empty when hi <= lo).
    lo: u32,
    hi: u32,
    /// Updates started.
    count: u32,
    /// The slot ticking now, or NONE.
    cursor: u32,
}

impl Default for Active {
    fn default() -> Self {
        Active {
            bits: Vec::new(),
            snapshot: Vec::new(),
            candidate: Vec::new(),
            doze: Vec::new(),
            wake: Vec::new(),
            lo: 0,
            hi: 0,
            count: 0,
            cursor: NONE,
        }
    }
}

impl Active {
    /// Room for `slots` characters.
    pub fn grow(&mut self, slots: usize) {
        let words = slots.div_ceil(64);
        if words > self.bits.len() {
            self.bits.resize(words, 0);
            self.snapshot.resize(words, 0);
            self.candidate.resize(words, 0);
            self.doze.resize(words, 0);
            self.wake.resize(words * 64, 0);
        }
    }
}

/// Bit i set where byte i of `bytes` equals `value`.
#[inline(always)]
fn wake_mask(bytes: &[u8; 64], value: u8) -> u64 {
    #[cfg(target_arch = "x86_64")]
    // SAFETY: SSE2 is baseline on x86_64; the loads are unaligned and in bounds.
    unsafe {
        use std::arch::x86_64::*;
        let v = _mm_set1_epi8(value as i8);
        let p = bytes.as_ptr() as *const __m128i;
        let m0 = _mm_movemask_epi8(_mm_cmpeq_epi8(_mm_loadu_si128(p), v)) as u16 as u64;
        let m1 = _mm_movemask_epi8(_mm_cmpeq_epi8(_mm_loadu_si128(p.add(1)), v)) as u16 as u64;
        let m2 = _mm_movemask_epi8(_mm_cmpeq_epi8(_mm_loadu_si128(p.add(2)), v)) as u16 as u64;
        let m3 = _mm_movemask_epi8(_mm_cmpeq_epi8(_mm_loadu_si128(p.add(3)), v)) as u16 as u64;
        m0 | m1 << 16 | m2 << 32 | m3 << 48
    }
    // SAFETY: NEON is baseline on aarch64.
    #[cfg(target_arch = "aarch64")]
    unsafe {
        wake_mask_neon(bytes, value)
    }
    #[cfg(not(any(target_arch = "x86_64", target_arch = "aarch64")))]
    {
        let mut mask = 0;
        for (i, &b) in bytes.iter().enumerate() {
            mask |= ((b == value) as u64) << i;
        }
        mask
    }
}

#[cfg(target_arch = "aarch64")]
#[target_feature(enable = "neon")]
#[inline]
fn wake_mask_neon(bytes: &[u8; 64], value: u8) -> u64 {
    use crate::utils::simd::{bits_u8x64, load_u8x64};
    use std::arch::aarch64::*;
    let (v, q) = (vdupq_n_u8(value), load_u8x64(bytes, 0));
    bits_u8x64(uint8x16x4_t(
        vceqq_u8(q.0, v),
        vceqq_u8(q.1, v),
        vceqq_u8(q.2, v),
        vceqq_u8(q.3, v),
    ))
}

impl Engine {
    // -------------------------------------------------------------- the set

    pub fn active_insert(&mut self, slot: u32) {
        let a = &mut self.active;
        let w = slot >> 6;
        a.bits[w as usize] |= 1 << (slot & 63);
        a.candidate[w as usize] |= 1 << (slot & 63);
        if a.hi <= a.lo {
            a.lo = w;
            a.hi = w + 1;
        } else {
            a.lo = a.lo.min(w);
            a.hi = a.hi.max(w + 1);
        }
    }

    pub fn active_remove(&mut self, slot: u32) {
        self.doze_wake(slot);
        self.active.bits[(slot >> 6) as usize] &= !(1 << (slot & 63));
    }

    #[inline]
    pub fn active_contains(&self, slot: u32) -> bool {
        self.active.bits[(slot >> 6) as usize] & (1 << (slot & 63)) != 0
    }

    /// Empty the set, waking every dozing character first.
    pub fn active_clear(&mut self) {
        for w in 0..self.active.doze.len() {
            let mut m = self.active.doze[w];
            while m != 0 {
                let slot = (w as u32) << 6 | m.trailing_zeros();
                m &= m - 1;
                self.doze_wake(slot);
            }
        }
        self.active.bits.fill(0);
        self.active.lo = 0;
        self.active.hi = 0;
    }

    pub fn active_is_empty(&self) -> bool {
        let a = &self.active;
        a.bits[a.lo as usize..a.hi.max(a.lo) as usize]
            .iter()
            .all(|&w| w == 0)
    }

    pub fn active_count(&self) -> usize {
        self.active
            .bits
            .iter()
            .map(|w| w.count_ones() as usize)
            .sum()
    }

    /// The active characters in ascending slot order.
    pub fn active_slots(&self) -> Vec<u32> {
        let mut out = Vec::new();
        for (w, &word) in self.active.bits.iter().enumerate() {
            let mut m = word;
            while m != 0 {
                out.push((w as u32) << 6 | m.trailing_zeros());
                m &= m - 1;
            }
        }
        out
    }

    /// The character's scene or path ended or was deactivated: the next prune
    /// checks it.
    #[inline(always)]
    pub fn mark_candidate(&mut self, slot: u32) {
        *self.active.candidate.at_mut(slot >> 6) |= 1 << (slot & 63);
    }

    /// EffectCharacter.is_active: an active path, or an active scene that is
    /// not complete (looping scenes read as complete).
    #[inline]
    pub fn is_active(&self, slot: u32) -> bool {
        *self.ch.path.at(slot) != NONE || !self.scene_is_complete(slot)
    }

    // -------------------------------------------------------------- dozing

    /// End the slot's doze, if any, settling its scene's ticks_elapsed.
    #[inline(always)]
    pub fn doze_wake(&mut self, slot: u32) {
        let w = (slot >> 6) as usize;
        let bit = 1u64 << (slot & 63);
        if *self.active.doze.at(w) & bit != 0 {
            self.doze_wake_slow(slot);
        }
    }

    #[cold]
    fn doze_wake_slow(&mut self, slot: u32) {
        let a = &mut self.active;
        let w = (slot >> 6) as usize;
        let bit = 1u64 << (slot & 63);
        a.doze[w] &= !bit;
        // ticks still owed: wake - update when this update's tick is still
        // ahead (it rejoins the snapshot), one less when it is behind us or no
        // update is running
        let mut owed = a.wake[slot as usize].wrapping_sub(a.count as u8) as u32;
        if a.cursor != NONE && slot >= a.cursor {
            a.snapshot[w] |= bit;
        } else {
            owed -= 1;
        }
        let scene = self.ch.scene[slot as usize];
        self.scenes.recs[scene as usize].ticks -= owed;
        self.doze_retire(scene);
    }

    /// A plain doze may end just after its head frame's last tick; that
    /// tick's retirement (never the scene's last frame) happens here.
    #[inline(always)]
    fn doze_retire(&mut self, scene: u32) {
        let rec = self.scenes.recs.at_mut(scene);
        if rec.ticks == rec.head_duration && rec.flags & SCF_EASED == 0 {
            rec.ticks = 0;
            rec.head += 1;
            self.scenes.load_head(scene);
        }
    }

    /// Doze through `k` pure ticks ahead (at most DOZE_MAX); returns the ticks
    /// dozed, 0 with a path or outside the set. Only update's own tick of the
    /// character calls this.
    #[inline(always)]
    pub(crate) fn doze_try(&mut self, slot: u32, k: u32) -> u32 {
        let k = k.min(DOZE_MAX);
        let w = (slot >> 6) as usize;
        let bit = 1u64 << (slot & 63);
        if *self.ch.path.at(slot) != NONE || *self.active.bits.at(w) & bit == 0 {
            return 0;
        }
        *self.active.doze.at_mut(w) |= bit;
        *self.active.wake.at_mut(slot) = self.active.count.wrapping_add(k + 1) as u8;
        k
    }

    // -------------------------------------------------------------- ticking

    /// EffectCharacter.tick: motion first, then animation.
    pub fn tick(&mut self, hooks: &mut dyn Hooks, slot: u32) {
        if self.ch.path[slot as usize] != NONE {
            self.motion_move(hooks, slot);
        }
        self.step_animation(hooks, slot);
    }

    /// BaseEffectIterator.update: tick a snapshot of the active set in
    /// ascending order, then prune.
    pub fn update(&mut self, hooks: &mut dyn Hooks) {
        let (on, timed) = self.batch.plan();
        let start = if timed {
            Some(std::time::Instant::now())
        } else {
            None
        };
        if on {
            self.update_with::<true>(hooks);
        } else {
            self.update_with::<false>(hooks);
        }
        if let Some(start) = start {
            self.batch.timed(on, start.elapsed().as_nanos() as u64);
        }
    }

    /// update, with or without motion_batch: without it the batched paths
    /// are compiled out of the tick loop. Two functions, not inlined: one
    /// body twice in update crowds out the inlining the tick loop needs.
    #[inline(never)]
    fn update_with<const BATCH: bool>(&mut self, hooks: &mut dyn Hooks) {
        let a = &mut self.active;
        let (lo, hi) = (a.lo as usize, a.hi as usize);
        a.count = a.count.wrapping_add(1);
        let now = a.count as u8;
        // the snapshot (callbacks may change the live set while we tick): this
        // update's dozers wake, the others stay out
        for w in lo..hi {
            let mut word = a.bits[w];
            let doze = a.doze[w];
            if doze != 0 {
                let wake: &[u8; 64] = a.wake[w * 64..w * 64 + 64].try_into().unwrap();
                let waking = wake_mask(wake, now) & doze;
                word &= !(doze ^ waking);
            }
            a.snapshot[w] = word;
        }
        for w in lo..hi {
            let word = *self.active.snapshot.at(w);
            if word == 0 {
                continue;
            }
            let epoch = self.motion_epoch;
            let mirrored = word & *self.paths.m.bits.at(w);
            let batched = if BATCH && mirrored != 0 {
                self.motion_batch(w, mirrored)
            } else {
                0
            };
            let (idle, bare) = if BATCH && mirrored != 0 {
                (self.batch.idle, self.batch.bare)
            } else {
                (0, 0)
            };
            self.batch.live = batched;
            *self.active.snapshot.at_mut(w) &= !idle;
            loop {
                // re-read: a woken character may have joined this word
                let m = *self.active.snapshot.at(w);
                if m == 0 {
                    break;
                }
                *self.active.snapshot.at_mut(w) = m & (m - 1);
                let slot = (w as u32) << 6 | m.trailing_zeros();
                self.active.cursor = slot;
                let bit = 1u64 << (slot & 63);
                // a batched step has a path, so no doze. Its result stands
                // while no callback ran since the batch (the epoch: only a
                // callback changes another character's path) and the slot's
                // mirror does (a tick can drop another's mirror, see batch.rs);
                // the mirror bit is the word the batch read, so this costs
                // one hot load where the full check below cost fireworks 2%
                if BATCH
                    && batched & bit != 0
                    && self.motion_epoch == epoch
                    && *self.paths.m.bits.at(w) & bit != 0
                {
                    debug_assert!(self.batched(slot, epoch));
                    if bare & bit != 0 {
                        self.bare_move(slot);
                    } else {
                        self.motion_apply(hooks, slot);
                        self.step_animation_awake(hooks, slot, false);
                        self.batch.hint = NONE;
                    }
                    continue;
                }
                let doze = self.active.doze.at_mut(w);
                if *doze & bit != 0 {
                    // its doze ran out: settle a pending retirement
                    *doze &= !bit;
                    let scene = *self.ch.scene.at(slot);
                    self.doze_retire(scene);
                }
                if *self.ch.path.at(slot) != NONE {
                    self.motion_move(hooks, slot);
                    self.step_animation_awake(hooks, slot, false);
                } else {
                    self.step_animation_awake(hooks, slot, true);
                }
            }
            self.batch.live = 0;
        }
        self.active.cursor = NONE;
        self.prune();
    }

    /// A callback is about to run (it may read or change any character's
    /// path): the batched steps of the characters after the ticking one are
    /// taken back out of their mirrors, and they tick after all, the idle
    /// ones included; no synced frame index of the batch stands any more.
    pub(super) fn motion_settle(&mut self) {
        self.batch.hint = NONE;
        let live = self.batch.live;
        if live == 0 {
            return;
        }
        self.batch.live = 0;
        let cursor = self.active.cursor;
        let (w, lane) = ((cursor >> 6) as usize, cursor & 63);
        let after = live & (!1u64 << lane);
        self.batch.restore(&mut self.paths.m, w, after);
        *self.active.snapshot.at_mut(w) |= after & self.batch.idle;
    }

    /// Drop the candidates that are no longer active, then narrow the window.
    fn prune(&mut self) {
        // the set may have grown during the pass
        let (lo, mut hi) = (self.active.lo as usize, self.active.hi as usize);
        for w in lo..hi {
            let mut m = self.active.candidate[w];
            if m == 0 {
                continue;
            }
            self.active.candidate[w] = 0;
            while m != 0 {
                let slot = (w as u32) << 6 | m.trailing_zeros();
                m &= m - 1;
                if !self.is_active(slot) {
                    self.active.bits[w] &= !(1 << (slot & 63));
                }
            }
        }
        let a = &mut self.active;
        let mut lo = lo;
        while lo < hi && a.bits[lo] == 0 {
            lo += 1;
        }
        if lo == hi {
            a.lo = 0;
            a.hi = 0;
            return;
        }
        while a.bits[hi - 1] == 0 {
            hi -= 1;
        }
        a.lo = lo as u32;
        a.hi = hi as u32;
    }
}

#[cfg(test)]
mod tests {
    use super::wake_mask;

    #[test]
    fn wake_mask_matches_scalar() {
        let mut x = 0x2545_f491_4f6c_dd1du64;
        for _ in 0..10_000 {
            let mut bytes = [0u8; 64];
            for b in &mut bytes {
                x = x
                    .wrapping_mul(6_364_136_223_846_793_005)
                    .wrapping_add(1_442_695_040_888_963_407);
                *b = (x >> 61) as u8;
            }
            let value = (x >> 40) as u8 & 7;
            let want = bytes
                .iter()
                .enumerate()
                .fold(0u64, |m, (i, &b)| m | ((b == value) as u64) << i);
            assert_eq!(wake_mask(&bytes, value), want);
        }
    }
}
