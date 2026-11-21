//! Scenes (engine/animation.rs Scene, Frame and the scene half of Animation,
//! with the stepping from engine/ctx.rs).
//!
//! A scene's frame queue is its head index: frames before it have played,
//! frames from it on remain. That is exactly the old engine's frames /
//! played_frames pair: frames retire in order, reset_scene restores the
//! original order, and synced/eased stepping index the remaining queue or the
//! whole list without reordering. Only a plain scene's head frame has nonzero
//! ticks_elapsed, so one counter per scene suffices, and the record caches
//! the head frame's visual and duration.
//!
//! A scene is split into the 32-byte hot record a tick touches and the cold
//! rest (name, map link, sync/easing state, preexisting colors).
//!
//! Frames live in one region; a scene appends in place while its frames end
//! it (effects build one scene at a time), else first moves them to the end.

use crate::engine::animation::{ExistingColorHandling, SyncMetric};
use crate::utils::easing::Easing;
use crate::utils::graphics::{Color, ColorPair};
use crate::utils::pycompat::round_half_even;

use super::batch::{NO_INDEX, SYNC_KEY_STEP};
use super::events::{Caller, Event};
use super::visual::{VisualInfo, BOLD, HAS_COLORS};
use super::{At, Engine, Hooks, Name, Sym, Visual, NONE};

pub type SceneId = u32;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[repr(C)]
pub struct Frame {
    pub visual: Visual,
    pub duration: u32,
}

pub const SCF_LOOPING: u32 = 1;
pub const SCF_SYNC: u32 = 2;
pub const SCF_EASED: u32 = 4;
pub const SCF_PREEXISTING: u32 = 8;
pub const SCF_PRE_BOLD: u32 = 16;
/// Synced by step (SyncMetric::Step); else by distance.
const SCF_SYNC_STEP: u32 = 32;
/// Synced: looked up in the share table since the last append.
const SCF_SHARED: u32 = 1 << 16;
/// Eased: the frames equal the tagged shape's reference frames.
const SCF_SHAPE_SAME: u32 = 64;
/// Eased: the shape (index + 1) the frames were compared with, 0 for none.
const SCF_SHAPE_TAG_SHIFT: u32 = 8;
const SCF_SHAPE_TAG: u32 = 127 << SCF_SHAPE_TAG_SHIFT;
const SCF_SHAPE: u32 = SCF_SHAPE_SAME | SCF_SHAPE_TAG;

/// Shapes memoized at most, and the longest memoized scene (in steps).
const SHAPE_LIMIT: usize = 64;
const EASED_MEMO_LIMIT: u32 = 1 << 16;
/// The longest doze (update.rs DOZE_MAX).
const DOZE_MAX: u32 = 254;

/// What a tick touches.
#[derive(Debug, Clone, Copy)]
#[repr(C, align(32))]
pub struct Scene {
    /// First frame in the region, frame count.
    pub start: u32,
    pub count: u32,
    /// Head of the remaining queue, and its ticks_elapsed (eased scenes:
    /// easing_current_step; synced scenes: the position + 1 of the frame
    /// shown last, 0 for none).
    pub head: u32,
    pub ticks: u32,
    /// The head frame (cached; stale while the queue is drained). Synced
    /// scenes keep the visual shown last in head_duration.
    pub head_visual: Visual,
    pub head_duration: u32,
    pub flags: u32,
    pub owner: u32,
}

impl Scene {
    #[inline]
    pub fn is_looping(&self) -> bool {
        self.flags & SCF_LOOPING != 0
    }

    #[inline]
    pub fn is_drained(&self) -> bool {
        self.head >= self.count
    }

    #[inline]
    pub fn remaining(&self) -> u32 {
        self.count - self.head
    }
}

/// A synced scene's key for motion_batch's frame index: the frames
/// remaining (final_frame_index + 1), bit 31 for a step-synced scene.
#[inline(always)]
pub(super) fn sync_key(rec: &Scene) -> u32 {
    rec.remaining()
        | if rec.flags & SCF_SYNC_STEP != 0 {
            SYNC_KEY_STEP
        } else {
            0
        }
}

#[derive(Debug, Clone)]
pub struct SceneCold {
    pub name: Name,
    /// Next scene of the same character, in insertion order.
    pub next: u32,
    pub sync: Option<SyncMetric>,
    /// Index into Scenes::eases (SCF_EASED only).
    pub ease: u32,
    /// easing_total_steps: the frames' total duration.
    pub ease_total: u32,
    /// Eased lookup cursor: a frame and its first tick.
    cursor: u32,
    cursor_start: u32,
    /// Index into Scenes::pre (SCF_PREEXISTING only).
    pre: u32,
}

/// Shared synced frame lists (see scene_share): the longest list shared,
/// the table size, and the new lists before the hit rate counts.
const SHARE_MAX_FRAMES: u32 = 64;
const SHARE_BITS: u32 = 16;
const SHARE_PROBATION: u32 = 256;

#[derive(Debug, Clone, Copy, Default)]
struct ShareEntry {
    start: u32,
    /// 0 for an empty entry.
    count: u32,
    tag: u32,
}

/// Consecutive records a scene name draws its indices from.
const SCENE_CHUNK: usize = 64;
/// Allocation cursors; names hash onto them (a collision just shares a chunk).
const SCENE_BANKS: usize = 64;

pub struct Scenes {
    pub recs: Vec<Scene>,
    pub cold: Vec<SceneCold>,
    pub frames: Vec<Frame>,
    eases: Vec<Easing>,
    /// Preexisting (fg, bg) colors of the scenes that use them.
    pre: Vec<(Option<Color>, Option<Color>)>,
    /// Eased shapes (see step_eased_scene), and the one found last.
    shapes: Vec<Shape>,
    shape_last: u32,
    /// Shared synced frame lists by content (SHARE_BITS open addressing).
    share: Vec<ShareEntry>,
    share_count: u32,
    share_hits: u32,
    share_off: bool,
    /// Per bank: the next index and the end of its chunk.
    banks: [(u32, u32); SCENE_BANKS],
    ease_memo: Vec<(u64, u32)>,
}

impl Default for Scenes {
    fn default() -> Self {
        Scenes {
            recs: Vec::new(),
            cold: Vec::new(),
            frames: Vec::new(),
            eases: Vec::new(),
            pre: Vec::new(),
            shapes: Vec::new(),
            shape_last: NONE,
            share: Vec::new(),
            share_count: 0,
            share_hits: 0,
            share_off: false,
            banks: [(0, 0); SCENE_BANKS],
            ease_memo: Vec::new(),
        }
    }
}

impl Scenes {
    #[inline]
    pub fn frames_of(&self, scene: SceneId) -> &[Frame] {
        let s = &self.recs[scene as usize];
        &self.frames[s.start as usize..(s.start + s.count) as usize]
    }

    #[inline]
    fn push_frame(&mut self, scene: SceneId, frame: Frame) {
        let region_end = self.frames.len() as u32;
        let s = &mut self.recs[scene as usize];
        if s.start + s.count != region_end {
            let (start, count) = (s.start as usize, s.count as usize);
            s.start = region_end;
            self.frames.extend_from_within(start..start + count);
        }
        self.frames.push(frame);
        let s = &mut self.recs[scene as usize];
        if s.count == s.head {
            s.head_visual = frame.visual;
            s.head_duration = frame.duration;
            if s.flags & SCF_EASED == 0 {
                s.ticks = 0;
            }
        }
        s.count += 1;
        s.flags &= !SCF_SHARED;
        if s.flags & SCF_EASED != 0 {
            s.flags &= !SCF_SHAPE;
            self.cold[scene as usize].ease_total += frame.duration;
        }
    }

    /// push_frame for a run of frames: one region check and one copy.
    fn push_frames(&mut self, scene: SceneId, frames: &[Frame]) {
        let Some(first) = frames.first() else {
            return;
        };
        let region_end = self.frames.len() as u32;
        let s = &mut self.recs[scene as usize];
        if s.start + s.count != region_end {
            let (start, count) = (s.start as usize, s.count as usize);
            s.start = region_end;
            self.frames.extend_from_within(start..start + count);
        }
        self.frames.extend_from_slice(frames);
        let s = &mut self.recs[scene as usize];
        if s.count == s.head {
            s.head_visual = first.visual;
            s.head_duration = first.duration;
            if s.flags & SCF_EASED == 0 {
                s.ticks = 0;
            }
        }
        s.count += frames.len() as u32;
        s.flags &= !SCF_SHARED;
        if s.flags & SCF_EASED != 0 {
            s.flags &= !SCF_SHAPE;
            self.cold[scene as usize].ease_total += frames.iter().map(|f| f.duration).sum::<u32>();
        }
    }

    /// A fresh record for a scene called `name`. Effects give every character
    /// the same scenes by name and tick them in slot order, so each name
    /// draws its indices from its own chunks of consecutive records:
    /// neighboring characters' active scenes then share cache lines.
    fn alloc(&mut self, name: Name, hot: Scene, cold: SceneCold) -> SceneId {
        let bank =
            (name.0.wrapping_mul(0x9E37_79B1) >> (32 - SCENE_BANKS.trailing_zeros())) as usize;
        let (next, end) = &mut self.banks[bank];
        if *next == *end {
            *next = self.recs.len() as u32;
            *end = *next + SCENE_CHUNK as u32;
            self.recs.resize(*end as usize, hot);
            self.cold.resize(*end as usize, cold.clone());
        }
        let id = *next;
        *next += 1;
        self.recs[id as usize] = hot;
        self.cold[id as usize] = cold;
        id
    }

    /// Room for this many more scenes and frames.
    pub fn reserve(&mut self, scenes: usize, frames: usize) {
        self.recs.reserve(scenes);
        self.cold.reserve(scenes);
        self.frames.reserve(frames);
    }

    /// Refresh the head cache after the head moved.
    #[inline(always)]
    pub(crate) fn load_head(&mut self, scene: SceneId) {
        let s = self.recs.at_mut(scene);
        if s.head < s.count {
            let at = s.start + s.head;
            let f = *self.frames.at(at);
            s.head_visual = f.visual;
            s.head_duration = f.duration;
            // the next cache line of frames, which the head reaches soon
            prefetch(
                self.frames
                    .as_ptr()
                    .wrapping_add(at as usize + 64 / size_of::<Frame>()),
            );
        }
    }
}

impl Engine {
    #[inline]
    pub fn scene(&self, scene: SceneId) -> &Scene {
        &self.scenes.recs[scene as usize]
    }

    #[inline]
    pub fn scene_name(&self, scene: SceneId) -> Name {
        self.scenes.cold[scene as usize].name
    }

    /// The character's active scene, or NONE.
    #[inline]
    pub fn active_scene(&self, slot: u32) -> SceneId {
        self.ch.scene[slot as usize]
    }

    /// Animation.scenes lookup by name.
    pub fn scene_find(&self, slot: u32, name: Name) -> Option<SceneId> {
        let mut s = self.ch.scenes[slot as usize];
        while s != NONE {
            let rec = &self.scenes.cold[s as usize];
            if rec.name == name {
                return Some(s);
            }
            s = rec.next;
        }
        None
    }

    fn scene_count_of(&self, slot: u32) -> usize {
        let mut n = 0;
        let mut s = self.ch.scenes[slot as usize];
        while s != NONE {
            n += 1;
            s = self.scenes.cold[s as usize].next;
        }
        n
    }

    /// `animation.scenes.clear()`: drop the character's scene map (the
    /// active scene, if any, stays active).
    pub fn scenes_clear(&mut self, slot: u32) {
        self.ch.scenes[slot as usize] = NONE;
    }

    /// Animation.new_scene. An empty `name` (Name::NONE) asks for the next
    /// auto id: the scene count, probing upward past taken ids. An existing
    /// name is overwritten in place, keeping its position in the map.
    pub fn scene_new(
        &mut self,
        slot: u32,
        name: Name,
        looping: bool,
        sync: Option<SyncMetric>,
        ease: Option<Easing>,
    ) -> SceneId {
        let name = if name == Name::NONE {
            let mut n = self.scene_count_of(slot);
            while self.scene_find(slot, Name::auto(n)).is_some() {
                n += 1;
            }
            Name::auto(n)
        } else {
            name
        };
        let mut flags = if looping { SCF_LOOPING } else { 0 };
        if let Some(sync) = sync {
            flags |= SCF_SYNC;
            if sync == SyncMetric::Step {
                flags |= SCF_SYNC_STEP;
            }
        } else if ease.is_some() {
            flags |= SCF_EASED;
        }
        let ease = match ease {
            Some(ease) => match self.scenes.eases.iter().position(|&e| e == ease) {
                Some(i) => i as u32,
                None => {
                    self.scenes.eases.push(ease);
                    self.scenes.eases.len() as u32 - 1
                }
            },
            None => NONE,
        };
        let mut pre = NONE;
        if self.config.existing_color_handling == ExistingColorHandling::Always
            && self.uses_preexisting_colors(slot)
        {
            flags |= SCF_PREEXISTING;
            if self.input_bold(slot) {
                flags |= SCF_PRE_BOLD;
            }
            pre = self.scenes.pre.len() as u32;
            self.scenes
                .pre
                .push((self.input_fg(slot), self.input_bg(slot)));
        }
        let hot = Scene {
            start: self.scenes.frames.len() as u32,
            count: 0,
            head: 0,
            ticks: 0,
            head_visual: Visual(NONE),
            head_duration: 0,
            flags,
            owner: slot,
        };
        let cold = SceneCold {
            name,
            next: NONE,
            sync,
            ease,
            ease_total: 0,
            cursor: 0,
            cursor_start: 0,
            pre,
        };
        if let Some(existing) = self.scene_find(slot, name) {
            self.doze_wake(slot);
            let next = self.scenes.cold[existing as usize].next;
            self.scenes.recs[existing as usize] = hot;
            self.scenes.cold[existing as usize] = SceneCold { next, ..cold };
            // an active scene emptied in place ends the character's activity
            self.mark_candidate(slot);
            return existing;
        }
        let id = self.scenes.alloc(name, hot, cold);
        let head = self.ch.scenes[slot as usize];
        if head == NONE {
            self.ch.scenes[slot as usize] = id;
        } else {
            let mut s = head;
            while self.scenes.cold[s as usize].next != NONE {
                s = self.scenes.cold[s as usize].next;
            }
            self.scenes.cold[s as usize].next = id;
        }
        id
    }

    /// Scene.add_frame: preexisting colors replace the given ones and
    /// preexisting bold forces bold.
    pub fn add_frame(
        &mut self,
        scene: SceneId,
        sym: Sym,
        duration: i64,
        colors: Option<ColorPair>,
        attrs: u16,
    ) -> Result<(), String> {
        let flags = self.scenes.recs[scene as usize].flags;
        let mut attrs = attrs;
        let mut colors = colors;
        if flags & SCF_PREEXISTING != 0 {
            let (fg, bg) = self.scenes.pre[self.scenes.cold[scene as usize].pre as usize];
            colors = Some(ColorPair::new(fg, bg));
        }
        if flags & SCF_PRE_BOLD != 0 {
            attrs |= BOLD;
        }
        if duration < 1 {
            return Err(format!(
                "Frame duration must be at least 1. Received: {duration}"
            ));
        }
        let (fg, bg) = match colors {
            Some(pair) => {
                attrs |= HAS_COLORS;
                (pair.fg_color, pair.bg_color)
            }
            None => (None, None),
        };
        let visual = self
            .visuals
            .make(&self.symbols, VisualInfo { sym, fg, bg, attrs });
        self.scenes.push_frame(
            scene,
            Frame {
                visual,
                duration: duration as u32,
            },
        );
        Ok(())
    }

    /// add_frame with a visual the effect built itself; under preexisting
    /// colors it is rebuilt with them, exactly as add_frame would.
    #[inline]
    pub fn add_frame_visual(
        &mut self,
        scene: SceneId,
        visual: Visual,
        duration: i64,
    ) -> Result<(), String> {
        let flags = self.scenes.recs[scene as usize].flags;
        if flags & (SCF_PREEXISTING | SCF_PRE_BOLD) != 0 {
            let info = self.visuals.info(visual);
            return self.add_frame(
                scene,
                info.sym,
                duration,
                info.colors(),
                info.attrs & !HAS_COLORS,
            );
        }
        if duration < 1 {
            return Err(format!(
                "Frame duration must be at least 1. Received: {duration}"
            ));
        }
        self.scenes.push_frame(
            scene,
            Frame {
                visual,
                duration: duration as u32,
            },
        );
        Ok(())
    }

    /// Appends another scene's frames (made for an equivalent scene), without
    /// re-checking durations or applying preexisting colors.
    pub fn append_frames(&mut self, scene: SceneId, frames: &[Frame]) {
        self.scenes.push_frames(scene, frames);
    }

    /// add_frame_visual for each frame, in order.
    pub fn add_frames_visual(&mut self, scene: SceneId, frames: &[Frame]) -> Result<(), String> {
        let flags = self.scenes.recs[scene as usize].flags;
        if flags & (SCF_PREEXISTING | SCF_PRE_BOLD) != 0 || frames.iter().any(|f| f.duration < 1) {
            for f in frames {
                self.add_frame_visual(scene, f.visual, f.duration as i64)?;
            }
            return Ok(());
        }
        self.scenes.push_frames(scene, frames);
        Ok(())
    }

    /// A clone of `source` (frames, flags, playback state) inserted into the
    /// character's scene map under `name` (scene.clone() + insert).
    pub fn scene_copy(&mut self, slot: u32, source: SceneId, name: Name) -> SceneId {
        let id = self.scene_new(slot, name, false, None, None);
        let hot = self.scenes.recs[source as usize];
        let cold = self.scenes.cold[source as usize].clone();
        self.scenes.recs[id as usize] = Scene { owner: slot, ..hot };
        let dst = &mut self.scenes.cold[id as usize];
        let next = dst.next;
        *dst = SceneCold { name, next, ..cold };
        id
    }

    /// Scene.apply_gradient_to_symbols with the exact cyclic_distribution
    /// semantics.
    pub fn apply_gradient(
        &mut self,
        scene: SceneId,
        symbols: &[Sym],
        duration: i64,
        fg: Option<&[Color]>,
        bg: Option<&[Color]>,
    ) -> Result<(), String> {
        let fg_has = fg.is_some_and(|g| !g.is_empty());
        let bg_has = bg.is_some_and(|g| !g.is_empty());
        if fg.is_none() && bg.is_none() {
            return Err("Foreground and background gradient are None. At least one gradient must be provided.".into());
        }
        if !fg_has && !bg_has {
            return Err(
                "Foreground and background gradient are empty. At least one gradient must have at least one color."
                    .into(),
            );
        }
        for &sym in symbols {
            let symbol = self.symbols.get(sym);
            if symbol.chars().count() > 1 {
                return Err(format!(
                    "Symbol must be a string with a length of 1. Received: `{symbol}`."
                ));
            }
        }
        let pairs: Vec<ColorPair> = if fg_has && bg_has {
            let (fg, bg) = (fg.unwrap(), bg.unwrap());
            if fg.len() >= bg.len() {
                cyclic_distribution(fg.len(), bg.len())
                    .map(|(f, b)| ColorPair::new(Some(fg[f]), Some(bg[b])))
                    .collect()
            } else {
                cyclic_distribution(bg.len(), fg.len())
                    .map(|(b, f)| ColorPair::new(Some(fg[f]), Some(bg[b])))
                    .collect()
            }
        } else if fg_has {
            fg.unwrap()
                .iter()
                .map(|&c| ColorPair::new(Some(c), None))
                .collect()
        } else {
            bg.unwrap()
                .iter()
                .map(|&c| ColorPair::new(None, Some(c)))
                .collect()
        };
        if symbols.len() >= pairs.len() {
            for (s, p) in cyclic_distribution(symbols.len(), pairs.len()) {
                self.add_frame(scene, symbols[s], duration, Some(pairs[p]), 0)?;
            }
        } else {
            for (p, s) in cyclic_distribution(pairs.len(), symbols.len()) {
                self.add_frame(scene, symbols[s], duration, Some(pairs[p]), 0)?;
            }
        }
        Ok(())
    }

    /// Scene.reset_scene: every frame back in the queue in original order,
    /// tick counters and the easing step zeroed.
    pub fn scene_reset(&mut self, scene: SceneId) {
        let owner = self.scenes.recs[scene as usize].owner;
        self.doze_wake(owner);
        let rec = &mut self.scenes.recs[scene as usize];
        rec.head = 0;
        rec.ticks = 0;
        self.scenes.load_head(scene);
    }

    /// `scene.ease = Some(ease)` on an existing scene. Its playback is kept;
    /// a scene that was not eased starts at easing step 0 (plain stepping
    /// never advances easing_current_step). A synced scene only records it.
    pub fn scene_set_ease(&mut self, scene: SceneId, ease: Easing) {
        let owner = self.scenes.recs[scene as usize].owner;
        self.doze_wake(owner);
        // callers re-ease many scenes with the easing added last
        let eases = &mut self.scenes.eases;
        let index = match eases.last() {
            Some(&last) if last == ease => eases.len() as u32 - 1,
            _ => match eases.iter().position(|&e| e == ease) {
                Some(i) => i as u32,
                None => {
                    eases.push(ease);
                    eases.len() as u32 - 1
                }
            },
        };
        self.scenes.cold[scene as usize].ease = index;
        let rec = &mut self.scenes.recs[scene as usize];
        if rec.flags & SCF_SYNC != 0 {
            return;
        }
        if rec.flags & SCF_EASED == 0 {
            rec.flags |= SCF_EASED;
            rec.ticks = 0;
            let total = self
                .scenes
                .frames_of(scene)
                .iter()
                .map(|f| f.duration)
                .sum();
            self.scenes.cold[scene as usize].ease_total = total;
        }
        self.scenes.recs[scene as usize].flags &= !SCF_SHAPE;
    }

    // ------------------------------------------------------------ activation

    /// Animation.activate_scene: resume semantics - the visual is the head of
    /// the remaining queue and playback is not reset.
    pub fn activate_scene(&mut self, hooks: &mut dyn Hooks, slot: u32, scene: SceneId) {
        // the effect's slot, checked: doze_wake and show_visual index unchecked
        assert!((slot as usize) < self.ch.len(), "activate_scene: no character {slot}");
        self.doze_wake(slot);
        let rec = &self.scenes.recs[scene as usize];
        assert!(!rec.is_drained(), "activate_scene: empty scene");
        let visual = rec.head_visual;
        if rec.flags & (SCF_SYNC | SCF_SHARED) == SCF_SYNC {
            self.scenes.share(scene);
        }
        self.ch.scene[slot as usize] = scene;
        self.show_visual(slot, visual);
        if self.observes(slot, Event::SceneActivated) {
            let name = self.scenes.cold[scene as usize].name;
            self.handle_event(hooks, slot, Event::SceneActivated, Caller::Scene(name));
        }
    }

    pub fn activate_scene_name(&mut self, hooks: &mut dyn Hooks, slot: u32, name: Name) {
        let scene = self
            .scene_find(slot, name)
            .expect("activate_scene: scene not found");
        self.activate_scene(hooks, slot, scene);
    }

    /// Animation.deactivate_scene: any active scene, or only the named one.
    pub fn deactivate_scene(&mut self, slot: u32, name: Option<Name>) {
        let active = self.ch.scene[slot as usize];
        if active == NONE {
            return;
        }
        if name.is_none_or(|n| self.scenes.cold[active as usize].name == n) {
            self.doze_wake(slot);
            self.ch.scene[slot as usize] = NONE;
            self.mark_candidate(slot);
        }
    }

    /// Animation.active_scene_is_complete: no scene, no remaining frames, or
    /// a looping scene.
    #[inline]
    pub fn scene_is_complete(&self, slot: u32) -> bool {
        let active = *self.ch.scene.at(slot);
        if active == NONE {
            return true;
        }
        let rec = self.scenes.recs.at(active);
        rec.is_drained() || rec.is_looping()
    }

    // ------------------------------------------------------------ stepping

    /// Animation.step_animation plus _complete_scene_if_finished.
    pub fn step_animation(&mut self, hooks: &mut dyn Hooks, slot: u32) {
        // the effect's slot, checked: the steps below index unchecked
        assert!((slot as usize) < self.ch.len(), "step_animation: no character {slot}");
        self.doze_wake(slot);
        self.step_animation_awake(hooks, slot, false);
    }

    /// step_animation for a character known not to be dozing. `may_doze`:
    /// update's own tick, which may doze through the pure ticks ahead.
    #[inline(always)]
    pub(crate) fn step_animation_awake(
        &mut self,
        hooks: &mut dyn Hooks,
        slot: u32,
        may_doze: bool,
    ) {
        let scene = *self.ch.scene.at(slot);
        if scene == NONE || self.scenes.recs.at(scene).is_drained() {
            return;
        }
        self.step_scene(hooks, slot, scene, may_doze);
    }

    /// step_animation_awake for a scene with frames left.
    #[inline(always)]
    fn step_scene(&mut self, hooks: &mut dyn Hooks, slot: u32, scene: SceneId, may_doze: bool) {
        let rec = self.scenes.recs.at_mut(scene);
        if rec.flags & (SCF_SYNC | SCF_EASED) == 0 {
            // get_next_visual: the head frame's visual (usually shown already)
            let visual = rec.head_visual;
            let ticks = rec.ticks + 1;
            if ticks == rec.head_duration {
                rec.ticks = 0;
                rec.head += 1;
                if rec.head == rec.count {
                    if rec.is_looping() {
                        rec.head = 0;
                        self.scenes.load_head(scene);
                    }
                } else {
                    self.scenes.load_head(scene);
                }
                self.show_visual(slot, visual);
            } else {
                rec.ticks = ticks;
                if rec.is_looping() {
                    // SCENE_COMPLETE fires every tick for looping scenes
                    self.show_visual(slot, visual);
                    self.mark_candidate(slot);
                    if self.observes(slot, Event::SceneComplete) {
                        let name = self.scenes.cold[scene as usize].name;
                        self.handle_event(hooks, slot, Event::SceneComplete, Caller::Scene(name));
                    }
                    return;
                }
                // the next duration - ticks ticks are pure, but for the last
                // one on the last frame (its retirement completes the scene)
                if may_doze {
                    let mut k = rec.head_duration - ticks;
                    if rec.head + 1 == rec.count {
                        k -= 1;
                    }
                    if k > 0 {
                        let k = self.doze_try(slot, k);
                        self.scenes.recs.at_mut(scene).ticks += k;
                    }
                }
                self.show_visual(slot, visual);
                return;
            }
        } else if rec.flags & SCF_SYNC != 0 {
            self.step_synced_scene(slot, scene);
        } else {
            self.step_eased_scene(slot, scene, may_doze);
        }
        // complete_scene_if_finished
        let rec = self.scenes.recs.at_mut(scene);
        let looping = rec.is_looping();
        if !(rec.is_drained() || looping) {
            return;
        }
        if !looping {
            rec.head = 0;
            rec.ticks = 0;
            self.scenes.load_head(scene);
            *self.ch.scene.at_mut(slot) = NONE;
        }
        self.mark_candidate(slot);
        if self.observes(slot, Event::SceneComplete) {
            let name = self.scenes.cold[scene as usize].name;
            self.handle_event(hooks, slot, Event::SceneComplete, Caller::Scene(name));
        }
    }

    /// Animation._step_synced_scene. The frame shown last is cached in the
    /// record (position + 1 in `ticks`, visual in `head_duration`): a
    /// character usually takes several steps per frame. A position's frame
    /// never changes (lists are only appended to, and shared lists are equal).
    fn step_synced_scene(&mut self, slot: u32, scene: SceneId) {
        let path = *self.ch.path.at(slot);
        let rec = self.scenes.recs.at_mut(scene);
        let visual = if path == NONE {
            // no active path: jump to the final frame and force-complete
            let last = self.scenes.frames.at(rec.start + rec.count - 1).visual;
            rec.head = rec.count;
            last
        } else {
            // motion_batch's index, if it was for the scene's current key
            let key = sync_key(rec);
            let mut frame_index = self.batch.take_sync_index(slot);
            if *self.paths.m.sync.at(slot) != key {
                frame_index = NO_INDEX;
            }
            if frame_index == NO_INDEX {
                let p = self.paths.recs.at(path);
                let (current_step, last_distance_reached) = self.paths.progress(slot, path);
                let final_frame_index = rec.remaining() as i64 - 1;
                let progress_ratio = if rec.flags & SCF_SYNC_STEP != 0 {
                    current_step.max(1) as f64 / p.max_steps.max(1) as f64
                } else {
                    let total = p.total_distance.max(1.0);
                    let remaining = (p.total_distance - last_distance_reached).max(1.0);
                    let reached = (total - remaining).max(1.0);
                    reached / total
                };
                frame_index = round_half_even(final_frame_index as f64 * progress_ratio)
                    .min(final_frame_index)
                    .max(0) as u32;
                // a mirrored path: the batch works out the next steps' index
                let m = &mut self.paths.m;
                if *m.path.at(slot) == path && *m.sync.at(slot) != key {
                    *m.sync.at_mut(slot) = key;
                    m.synced = true;
                }
            }
            let pos = rec.head + frame_index;
            if pos + 1 == rec.ticks {
                Visual(rec.head_duration)
            } else {
                let visual = self.scenes.frames.at(rec.start + pos).visual;
                rec.ticks = pos + 1;
                rec.head_duration = visual.0;
                visual
            }
        };
        self.show_visual(slot, visual);
    }

    /// Whether step_animation_awake does nothing on this tick, given
    /// motion_batch's synced frame index `index` (for the slot's sync key):
    /// no frames remain, or the synced, non-looping scene shows that frame.
    #[inline(always)]
    pub(super) fn animation_idle(&self, slot: u32, scene: SceneId, index: u32) -> bool {
        let rec = self.scenes.recs.at(scene);
        if rec.is_drained() {
            return true;
        }
        rec.flags & (SCF_LOOPING | SCF_SYNC) == SCF_SYNC
            && index != NO_INDEX
            && *self.paths.m.sync.at(slot) == sync_key(rec)
            && rec.head + index + 1 == rec.ticks
            && rec.head_duration == self.ch.visual.at(slot).0
    }

    /// Animation._step_eased_scene. On update's tick (`may_doze`) the
    /// character dozes through the next steps that keep its visual and don't
    /// end the scene: found from the shape's visuals when the scene has its
    /// reference frames, else from its indexes and the frame just shown.
    #[inline(always)]
    fn step_eased_scene(&mut self, slot: u32, scene: SceneId, may_doze: bool) {
        let shape = self.scenes.shape_of(scene);
        let rec = *self.scenes.recs.at(scene);
        let same = rec.flags & SCF_SHAPE_SAME != 0;
        let step = rec.ticks;
        let (visual, total) = if shape != NONE {
            let sh = self.scenes.shapes.at(shape);
            let total = sh.total;
            let mut visual = if same {
                *sh.visual.at(step)
            } else {
                Visual(NONE)
            };
            if visual.0 == NONE {
                let mut index = *sh.index.at(step);
                if index == NONE {
                    index = self.scenes.ease_index(scene, step);
                    *self.scenes.shapes.at_mut(shape).index.at_mut(step) = index;
                }
                visual = self.scenes.frame_at_tick(scene, index);
                if same {
                    *self.scenes.shapes.at_mut(shape).visual.at_mut(step) = visual;
                }
            }
            (visual, total)
        } else {
            let index = self.scenes.ease_index(scene, step);
            (
                self.scenes.frame_at_tick(scene, index),
                self.scenes.cold.at(scene).ease_total,
            )
        };
        self.show_visual(slot, visual);
        let step = step + 1;
        let rec = self.scenes.recs.at_mut(scene);
        let looping = rec.is_looping();
        if step == total {
            if looping {
                rec.ticks = 0;
            } else {
                rec.ticks = step;
                rec.head = rec.count;
            }
            return;
        }
        rec.ticks = step;
        if !may_doze || shape == NONE || looping {
            return;
        }
        // steps before the last
        let n = (total - step - 1).min(DOZE_MAX) as usize;
        if n == 0 {
            return;
        }
        let sh = self.scenes.shapes.at(shape);
        let from = step as usize;
        let k = if same {
            sh.visual[from..from + n]
                .iter()
                .take_while(|&&v| v == visual)
                .count()
        } else {
            let cold = self.scenes.cold.at(scene);
            let start = cold.cursor_start;
            let duration = self.scenes.frames.at(rec.start + cold.cursor).duration;
            sh.index[from..from + n]
                .iter()
                .take_while(|&&i| i != NONE && i.wrapping_sub(start) < duration)
                .count()
        };
        if k > 0 {
            let k = self.doze_try(slot, k as u32);
            self.scenes.recs.at_mut(scene).ticks += k;
        }
    }

    // ------------------------------------------------------------ appearance

    /// Animation.set_appearance: the symbol (or the input symbol) with the
    /// given colors (or none). Under --existing-color-handling always, a
    /// character that uses its input colors shows those and its bold instead.
    pub fn set_appearance(&mut self, slot: u32, sym: Option<Sym>, colors: Option<ColorPair>) {
        let sym = sym.unwrap_or(self.ch.sym[slot as usize]);
        let mut colors = colors.unwrap_or_default();
        let mut attrs = HAS_COLORS;
        if self.config.existing_color_handling == ExistingColorHandling::Always
            && self.uses_preexisting_colors(slot)
        {
            colors = ColorPair::new(self.input_fg(slot), self.input_bg(slot));
            if self.input_bold(slot) {
                attrs |= BOLD;
            }
        }
        let visual = self.visuals.make(
            &self.symbols,
            VisualInfo {
                sym,
                fg: colors.fg_color,
                bg: colors.bg_color,
                attrs,
            },
        );
        self.doze_wake(slot);
        self.show_visual(slot, visual);
    }

    /// The RESET_APPEARANCE action: the input symbol with no colors.
    pub fn reset_appearance(&mut self, slot: u32) {
        self.set_appearance(slot, None, None);
    }
}

#[inline(always)]
fn prefetch<T>(value: *const T) {
    #[cfg(target_arch = "x86_64")]
    // SAFETY: prefetching is a hint; any address is allowed.
    unsafe {
        use std::arch::x86_64::{_mm_prefetch, _MM_HINT_T0};
        _mm_prefetch::<_MM_HINT_T0>(value as *const i8);
    }
    #[cfg(target_arch = "aarch64")]
    // SAFETY: prfm is a hint; any address is allowed.
    unsafe {
        std::arch::asm!("prfm pldl1keep, [{0}]", in(reg) value, options(nostack, readonly, preserves_flags));
    }
    #[cfg(not(any(target_arch = "x86_64", target_arch = "aarch64")))]
    let _ = value;
}

/// cyclic_distribution(larger, smaller): pairs of indices, in iteration order.
fn cyclic_distribution(larger: usize, smaller: usize) -> impl Iterator<Item = (usize, usize)> {
    let repeat_factor = larger / smaller;
    let mut overflow_count = larger % smaller;
    let mut overflow_used = false;
    let mut smaller_index = 0usize;
    let mut current_repeat_factor = 0usize;
    (0..larger).map(move |i| {
        if current_repeat_factor >= repeat_factor {
            if overflow_count > 0 {
                if overflow_used {
                    smaller_index += 1;
                    current_repeat_factor = 0;
                    overflow_used = false;
                } else {
                    overflow_used = true;
                    overflow_count -= 1;
                }
            } else {
                smaller_index += 1;
                current_repeat_factor = 0;
            }
        }
        current_repeat_factor += 1;
        (i, smaller_index)
    })
}

// ------------------------------------------------------------------ eased shapes
//
// An eased scene's frame index per step depends only on (easing, step,
// total), and effects give many characters the same shape, often with the
// same frames. A shape memoizes per step the index and, for scenes whose
// frames equal its reference frames (a copy of the first scene's), the
// visual; NONE is unknown. A scene's flags record the shape it was compared
// with (the tag) and whether its frames match; appending a frame clears both.

struct Shape {
    ease: u32,
    total: u32,
    index: Vec<u32>,
    visual: Vec<Visual>,
    reference: Vec<Frame>,
}

/// The tag of a scene whose shape is not memoized (too long, table full).
const SHAPE_TAG_NONE: u32 = 127;

impl Scenes {
    /// The eased scene's shape, or NONE when shapes are not memoized for it.
    #[inline(always)]
    fn shape_of(&mut self, scene: SceneId) -> u32 {
        let tag = (self.recs.at(scene).flags & SCF_SHAPE_TAG) >> SCF_SHAPE_TAG_SHIFT;
        match tag {
            0 => self.shape_attach(scene),
            SHAPE_TAG_NONE => NONE,
            _ => tag - 1,
        }
    }

    /// Find (or claim) the scene's shape and compare its frames with the
    /// shape's reference frames, recording both in its flags.
    #[cold]
    fn shape_attach(&mut self, scene: SceneId) -> u32 {
        let cold = &self.cold[scene as usize];
        let (ease, total) = (cold.ease, cold.ease_total);
        let found = if self.shape_last != NONE && {
            let sh = &self.shapes[self.shape_last as usize];
            sh.ease == ease && sh.total == total
        } {
            Some(self.shape_last)
        } else {
            self.shapes
                .iter()
                .position(|sh| sh.ease == ease && sh.total == total)
                .map(|i| i as u32)
        };
        let shape = match found {
            Some(shape) => shape,
            None if self.shapes.len() < SHAPE_LIMIT && total <= EASED_MEMO_LIMIT => {
                let reference = self.frames_of(scene).to_vec();
                self.shapes.push(Shape {
                    ease,
                    total,
                    index: vec![NONE; total as usize],
                    visual: vec![Visual(NONE); total as usize],
                    reference,
                });
                self.shapes.len() as u32 - 1
            }
            None => {
                self.recs[scene as usize].flags |= SHAPE_TAG_NONE << SCF_SHAPE_TAG_SHIFT;
                return NONE;
            }
        };
        self.shape_last = shape;
        let mut flags =
            self.recs[scene as usize].flags & !SCF_SHAPE | (shape + 1) << SCF_SHAPE_TAG_SHIFT;
        if self.frames_of(scene) == self.shapes[shape as usize].reference.as_slice() {
            flags |= SCF_SHAPE_SAME;
        }
        self.recs[scene as usize].flags = flags;
        shape
    }

    /// The frame index an eased scene shows at `step`:
    /// round(ease(step / total) * final).min(final).max(0).
    fn ease_index(&mut self, scene: SceneId, step: u32) -> u32 {
        let cold = self.cold.at(scene);
        let key = (cold.ease as u64) << 42 | (cold.ease_total as u64) << 21 | step as u64 | 1 << 63;
        let fits = cold.ease_total < 1 << 21 && cold.ease < 1 << 20;
        if self.ease_memo.is_empty() {
            self.ease_memo = vec![(0, 0); 1 << 13];
        }
        let slot = (key.wrapping_mul(0x9E37_79B9_7F4A_7C15) >> (64 - 13)) as usize;
        if fits && self.ease_memo.at(slot).0 == key {
            return self.ease_memo.at(slot).1;
        }
        let cold = self.cold.at(scene);
        let ease = *self.eases.at(cold.ease);
        let easing_factor = ease.ease(step as f64 / cold.ease_total as f64);
        let final_frame_index = (cold.ease_total as i64 - 1).max(0);
        let index = round_half_even(easing_factor * final_frame_index as f64)
            .min(final_frame_index)
            .max(0) as u32;
        if fits {
            *self.ease_memo.at_mut(slot) = (key, index);
        }
        index
    }

    /// frame_index_map[tick]: the visual of the frame whose tick range holds
    /// `tick`, walking a cursor (frame, its first tick) from the last lookup.
    fn frame_at_tick(&mut self, scene: SceneId, tick: u32) -> Visual {
        let start = self.recs.at(scene).start;
        let frames = &self.frames;
        let cold = self.cold.at_mut(scene);
        let (mut cursor, mut first) = (cold.cursor, cold.cursor_start);
        while tick < first {
            cursor -= 1;
            first -= frames.at(start + cursor).duration;
        }
        loop {
            let end = first + frames.at(start + cursor).duration;
            if tick < end {
                break;
            }
            first = end;
            cursor += 1;
        }
        cold.cursor = cursor;
        cold.cursor_start = first;
        frames.at(start + cursor).visual
    }
}

// ------------------------------------------------------------------ shared frames
//
// Effects often give many characters identical frame lists. Synced stepping
// reads a list every tick, so on activation a synced scene's frames are
// looked up by content and the scene points at the first list seen with it.
// (Plain scenes read theirs once per frame; there lookups cost more than
// they save.) The region is append-only and a scene appends in place only at
// its end, so no scene can change another's frames. Appending clears
// SCF_SHARED, and the next activation looks the list up again.

impl Scenes {
    /// Point the synced scene at the shared copy of its frames.
    fn share(&mut self, scene: SceneId) {
        let rec = &mut self.recs[scene as usize];
        rec.flags |= SCF_SHARED;
        if self.share_off || rec.count > SHARE_MAX_FRAMES {
            return;
        }
        if self.share.is_empty() {
            self.share = vec![ShareEntry::default(); 1 << SHARE_BITS];
        }
        let (start, count) = (rec.start, rec.count);
        let frames = &self.frames[start as usize..(start + count) as usize];
        // order-sensitive: a running sum and the xor of its prefixes
        let (mut sum, mut prefixes) = (count as u64, 0u64);
        for f in frames {
            sum = sum.wrapping_add(f.visual.0 as u64 | (f.duration as u64) << 32);
            prefixes ^= sum;
        }
        const K: u64 = 0x9E37_79B9_7F4A_7C15;
        let hash = (sum.wrapping_mul(K) ^ prefixes.rotate_left(29)).wrapping_mul(K);
        let tag = hash as u32;
        let mask = (1usize << SHARE_BITS) - 1;
        let mut i = (hash >> (64 - SHARE_BITS)) as usize;
        loop {
            let entry = self.share[i];
            if entry.count == 0 {
                break;
            }
            if entry.tag == tag
                && entry.count == count
                && self.frames[entry.start as usize..(entry.start + count) as usize] == *frames
            {
                self.recs[scene as usize].start = entry.start;
                self.share_hits += 1;
                return;
            }
            i = (i + 1) & mask;
        }
        // a new list; when few lists repeat, lookups cost more than sharing
        // saves, so they stop for the rest of the run
        let n = self.share_count;
        if n >= (1 << SHARE_BITS) * 3 / 4 || (n >= SHARE_PROBATION && self.share_hits * 4 < n) {
            self.share_off = true;
            return;
        }
        self.share_count += 1;
        self.share[i] = ShareEntry { start, count, tag };
    }
}
