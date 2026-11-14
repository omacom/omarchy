//! Motion (engine/motion.rs and the motion half of engine/ctx.rs).
//!
//! Paths are records in one table, linked per character in insertion order.
//! Waypoints and segments live in two shared regions, like scene frames: a
//! path appends in place while its block ends the region, else first moves
//! the block to the end. A segment block starts with a reserved slot for the
//! origin segment activation writes, so the walk's list (`[origin] +
//! segments` once activated) is contiguous and activation never shifts it.
//!
//! Bezier control lists are interned: a waypoint holds an id (NONE for
//! none), so waypoint keys compare by value as the old engine's do. Eased
//! paths read ease(step / max_steps) from a factor table shared by every
//! path with the same easing and max_steps.
//!
//! Mirrors. The old engine's step reads the path record, its segments, the
//! controls and the easing, all scattered per character. Here each slot
//! keeps, in slot-indexed arrays, what its next pure steps need (`Mirrors`):
//! the path, the step, max_steps, the total distance, the factor table, and
//! one segment (its ends and control as floats, its distance and the
//! distance before it). A destination `d` with `d - off` within the segment
//! (and above `off` past the first segment) is where the walk lands without
//! an event. A destination past every segment (eased overshoot) lands in the
//! last one through the walk's for-else, at `(d - off) + hi` (MF_OVER).
//! While a mirror stands it holds the path's current_step and
//! last_distance_reached (the record's are stale), writes them back when
//! dropped (`release`), and the synced scene step reads them through
//! `progress`. A mirror is made after a walked step that lands where the
//! next can take the fast case, and dropped when its path changes, when the
//! slot's active path changes, when a step leaves the segment, and when a
//! step reaches max_steps (Motion.move's tail reads the record).

use std::collections::HashMap;

use crate::utils::easing::Easing;
use crate::utils::geometry::{self, Coord};
use crate::utils::pycompat::round_half_even;

use super::events::{Caller, Event, WaypointKey};
use super::{At, Engine, FxBuild, Hooks, Name, NONE};

// Path flags.
const PF_LOOP: u32 = 1;
const PF_LAYER: u32 = 2;
/// The origin slot holds activation's origin segment.
const PF_ORIGIN: u32 = 4;

/// Factor tables are kept for paths of at most this many steps.
const ETAB_MAX_STEPS: i64 = 1 << 16;

// Mirror flags.
/// The segment is past the first: d must exceed `off`.
pub(super) const MF_LOWER: u8 = 1;
/// A curve through one control point.
pub(super) const MF_CURVE: u8 = 2;
/// A linear ratio (clamped to 1.0); eased paths overshoot unclamped.
pub(super) const MF_CLAMP: u8 = 4;
/// Past the end of the path (the walk's for-else): `off` is every
/// segment's distance, and the last segment's is added back.
pub(super) const MF_OVER: u8 = 8;

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Waypoint {
    pub coord: Coord,
    pub name: Name,
    /// Interned bezier control list, NONE when there is none.
    pub bezier: u32,
}

impl Waypoint {
    #[inline]
    pub fn key(&self) -> WaypointKey {
        WaypointKey {
            coord: self.coord,
            name: self.name,
            bezier: self.bezier,
        }
    }
}

#[derive(Debug, Clone, Copy)]
pub struct Segment {
    pub start: Waypoint,
    pub end: Waypoint,
    pub distance: f64,
    pub entered: bool,
    pub exited: bool,
}

pub struct Path {
    pub name: Name,
    /// Next path of the same character, in insertion order.
    pub next: u32,
    flags: u32,
    /// Index into Paths::eases, NONE without easing.
    ease: u32,
    layer: i32,
    speed: f64,
    hold: i64,
    hold_left: i64,
    pub total_distance: f64,
    pub current_step: i64,
    pub max_steps: i64,
    pub last_distance_reached: f64,
    /// The origin segment's distance (PF_ORIGIN).
    origin_distance: f64,
    /// The segment block (the origin slot, then the segments between
    /// waypoints; NONE until the first waypoint) and its segment count.
    seg_base: u32,
    seg_count: u32,
    wp_start: u32,
    wp_count: u32,
    /// Offset of the eased factor table in Paths::etab; 0 when not looked up
    /// yet, NONE when there is none.
    etab: u32,
    /// The slot whose mirror describes this path, or NONE.
    mslot: u32,
}

impl Path {
    /// The walk's segment list in the region: [origin] + segments.
    #[inline]
    fn segs(&self) -> (u32, u32) {
        if self.flags & PF_ORIGIN != 0 {
            (self.seg_base, self.seg_count + 1)
        } else {
            (self.seg_base.wrapping_add(1), self.seg_count)
        }
    }
}

pub struct Paths {
    pub recs: Vec<Path>,
    segs: Vec<Segment>,
    wps: Vec<Waypoint>,
    eases: Vec<Easing>,
    beziers: Vec<Box<[Coord]>>,
    bezier_ids: HashMap<Box<[Coord]>, u32, FxBuild>,
    /// Eased factor tables, by (easing, max_steps).
    etab: Vec<f64>,
    etab_map: HashMap<(u32, i64), u32, FxBuild>,
    pub m: Mirrors,
}

/// Per slot: what its next pure steps need (see the module notes).
#[derive(Default)]
pub struct Mirrors {
    /// The path described, or NONE.
    pub path: Vec<u32>,
    /// A bit per slot: it has a mirror (`path` is not NONE).
    pub bits: Vec<u64>,
    /// current_step, last_distance_reached (the path's, while the mirror
    /// stands), max_steps and total_distance.
    pub step: Vec<f64>,
    pub last: Vec<f64>,
    pub max: Vec<f64>,
    pub total: Vec<f64>,
    /// The factor table's offset, 0 for a linear ratio.
    pub etab: Vec<u32>,
    /// The distance before the segment, and the segment's.
    pub off: Vec<f64>,
    pub hi: Vec<f64>,
    pub flags: Vec<u8>,
    /// The segment's start, control (the end for a line) and end.
    pub sx: Vec<f64>,
    pub sy: Vec<f64>,
    pub cx: Vec<f64>,
    pub cy: Vec<f64>,
    pub ex: Vec<f64>,
    pub ey: Vec<f64>,
    /// The sync key (`Scenes::sync_key`) the slot last showed a synced frame
    /// with, 0 for none: motion_batch works out that frame index with each
    /// step. A filter only, kept across mirrors.
    pub sync: Vec<u32>,
    /// Some slot has a sync key.
    pub synced: bool,
}

/// A mirrored step: the step, the distance reached, the unrounded coordinate.
pub(super) struct MirrorStep {
    pub step: f64,
    pub d: f64,
    pub x: f64,
    pub y: f64,
}

impl Mirrors {
    pub fn grow(&mut self, slots: usize) {
        if self.path.len() < slots {
            // geometric, in whole words (the batch reads groups of 8 lanes)
            let slots = slots.max(self.path.len() * 2).max(64).next_multiple_of(64);
            self.path.resize(slots, NONE);
            self.bits.resize(slots / 64, 0);
            for v in [
                &mut self.step,
                &mut self.last,
                &mut self.max,
                &mut self.total,
                &mut self.off,
                &mut self.hi,
                &mut self.sx,
                &mut self.sy,
                &mut self.cx,
                &mut self.cy,
                &mut self.ex,
                &mut self.ey,
            ] {
                v.resize(slots, 0.0);
            }
            self.etab.resize(slots, 0);
            self.sync.resize(slots, 0);
            self.flags.resize(slots, 0);
        }
    }

    /// The next step through the slot's mirror, changing nothing: None when
    /// it is not pure.
    #[inline(always)]
    // the negated compares are the walk's own: NaN fails them
    #[allow(clippy::neg_cmp_op_on_partial_ord)]
    pub(super) fn next_step(&self, etab: &[f64], slot: u32) -> Option<MirrorStep> {
        let step = *self.step.at(slot) + 1.0;
        let max = *self.max.at(slot);
        if !(step <= max) {
            return None;
        }
        let tab = *self.etab.at(slot);
        let factor = if tab == 0 {
            step / max
        } else {
            *etab.at(tab as usize + step as usize)
        };
        let d = factor * *self.total.at(slot);
        let (off, hi, flags) = (*self.off.at(slot), *self.hi.at(slot), *self.flags.at(slot));
        let mut r = d - off;
        if flags & MF_OVER != 0 {
            if !(d > off) {
                return None;
            }
            r += hi;
        } else if !(r <= hi && (flags & MF_LOWER == 0 || d > off)) {
            return None;
        }
        let t = if hi == 0.0 {
            0.0
        } else if flags & MF_CLAMP != 0 {
            (r / hi).min(1.0)
        } else {
            r / hi
        };
        let (sx, sy, ex, ey) = (
            *self.sx.at(slot),
            *self.sy.at(slot),
            *self.ex.at(slot),
            *self.ey.at(slot),
        );
        let u = 1.0 - t;
        let (x, y) = if flags & MF_CURVE == 0 {
            (u * sx + t * ex, u * sy + t * ey)
        } else {
            let (cx, cy) = (*self.cx.at(slot), *self.cy.at(slot));
            let (ax, ay) = (u * sx + t * cx, u * sy + t * cy);
            let (bx, by) = (u * cx + t * ex, u * cy + t * ey);
            (u * ax + t * bx, u * ay + t * by)
        };
        Some(MirrorStep { step, d, x, y })
    }

    #[inline(always)]
    fn drop_slot(&mut self, slot: u32) {
        *self.path.at_mut(slot) = NONE;
        *self.bits.at_mut(slot >> 6) &= !(1 << (slot & 63));
    }
}

impl Default for Paths {
    fn default() -> Self {
        Paths {
            recs: Vec::new(),
            segs: Vec::new(),
            wps: Vec::new(),
            eases: Vec::new(),
            beziers: Vec::new(),
            bezier_ids: HashMap::default(),
            // offset 0 means "not looked up"
            etab: vec![0.0],
            etab_map: HashMap::default(),
            m: Mirrors::default(),
        }
    }
}

impl Paths {
    /// The coordinate `distance` into region segment `seg` (eased: unclamped).
    #[inline(always)]
    fn coord_in(&self, path: u32, seg: u32, distance: f64) -> Coord {
        let seg = self.segs.at(seg as usize);
        let t = if seg.distance == 0.0 {
            0.0
        } else if self.recs.at(path).ease != NONE {
            distance / seg.distance
        } else {
            (distance / seg.distance).min(1.0)
        };
        if seg.end.bezier == NONE {
            geometry::find_coord_on_line(seg.start.coord, seg.end.coord, t)
        } else {
            geometry::find_coord_on_bezier_curve(
                seg.start.coord,
                self.bezier(seg.end.bezier),
                seg.end.coord,
                t,
            )
        }
    }

    fn intern_bezier(&mut self, control: &[Coord]) -> u32 {
        if let Some(&id) = self.bezier_ids.get(control) {
            return id;
        }
        let id = self.beziers.len() as u32;
        self.beziers.push(control.into());
        self.bezier_ids.insert(control.into(), id);
        id
    }

    #[inline]
    pub fn bezier(&self, id: u32) -> &[Coord] {
        &self.beziers[id as usize]
    }

    /// The distance from `start` to the waypoint (a curve through its
    /// controls, or a line with doubled rows).
    fn distance_to(&self, start: Coord, end: &Waypoint) -> f64 {
        if end.bezier == NONE {
            geometry::find_length_of_line(start, end.coord, true)
        } else {
            geometry::find_length_of_bezier_curve(start, self.bezier(end.bezier), end.coord)
        }
    }

    /// The factor table of an eased path: ease(step / max_steps) at
    /// `etab[offset + step]`, or NONE.
    fn ease_table(&mut self, path: u32) -> u32 {
        let p = &self.recs[path as usize];
        let max_steps = p.max_steps;
        let offset = if max_steps > ETAB_MAX_STEPS {
            NONE
        } else {
            let key = (p.ease, max_steps);
            match self.etab_map.get(&key) {
                Some(&offset) => offset,
                None => {
                    // paths nearly always walk their table to the end
                    let offset = self.etab.len() as u32;
                    let ease = *self.eases.at(p.ease);
                    self.etab.extend(
                        (0..=max_steps).map(|step| ease.ease(step as f64 / max_steps as f64)),
                    );
                    self.etab_map.insert(key, offset);
                    offset
                }
            }
        };
        self.recs[path as usize].etab = offset;
        offset
    }

    /// The distance factor of an eased path at `step` (Path.step's
    /// ease(current_step / max_steps)).
    #[inline]
    fn eased_factor(&mut self, path: u32, step: i64) -> f64 {
        let mut offset = self.recs.at(path).etab;
        if offset == 0 {
            offset = self.ease_table(path);
        }
        if offset != NONE {
            return *self.etab.at(offset as usize + step as usize);
        }
        self.eased_factor_slow(path, step)
    }

    /// eased_factor without a table.
    #[cold]
    fn eased_factor_slow(&mut self, path: u32, step: i64) -> f64 {
        let p = self.recs.at(path);
        self.eases.at(p.ease).ease(step as f64 / p.max_steps as f64)
    }

    #[inline(always)]
    pub(super) fn mirrors_etab(&mut self) -> (&mut Mirrors, &[f64]) {
        (&mut self.m, &self.etab)
    }

    /// Drop the slot's mirror, if any, writing its step and last distance
    /// back to the path.
    #[inline]
    pub(super) fn release(&mut self, slot: u32) {
        let path = *self.m.path.at(slot);
        if path != NONE {
            let p = self.recs.at_mut(path);
            p.current_step = *self.m.step.at(slot) as i64;
            p.last_distance_reached = *self.m.last.at(slot);
            p.mslot = NONE;
            self.m.drop_slot(slot);
        }
    }

    /// Drop the mirror describing this path, if any.
    #[inline]
    fn unmirror(&mut self, path: u32) {
        let slot = self.recs.at(path).mslot;
        if slot != NONE {
            self.release(slot);
        }
    }

    /// The path's (current_step, last_distance_reached), through the slot's
    /// mirror while it stands.
    #[inline(always)]
    pub(super) fn progress(&self, slot: u32, path: u32) -> (i64, f64) {
        if *self.m.path.at(slot) == path {
            (*self.m.step.at(slot) as i64, *self.m.last.at(slot))
        } else {
            let p = self.recs.at(path);
            (p.current_step, p.last_distance_reached)
        }
    }

    /// A step of `slot` on `path` landed in walk segment `k` (every segment
    /// before it entered and exited, this one entered), or past the end
    /// (`over`, k the last segment; every segment entered and exited):
    /// mirror the path when the next steps can take the fast case.
    #[allow(clippy::neg_cmp_op_on_partial_ord)] // NaN and infinities are refused
    fn mirror(&mut self, slot: u32, path: u32, k: u32, over: bool) {
        const EXACT: f64 = (1u64 << 52) as f64;
        // the record must be current, and one mirror per slot and per path
        self.release(slot);
        self.unmirror(path);
        let p = self.recs.at(path);
        if p.max_steps <= 0 || !(p.total_distance != 0.0 && p.total_distance.abs() < EXACT) {
            return;
        }
        let etab = if p.ease == NONE {
            0
        } else {
            let mut offset = p.etab;
            if offset == 0 {
                offset = self.ease_table(path);
            }
            if offset == NONE {
                return;
            }
            offset
        };
        let p = self.recs.at(path);
        let (first, _) = p.segs();
        let seg = *self.segs.at(first + k);
        let mut flags = if p.ease == NONE { MF_CLAMP } else { 0 };
        let control = if seg.end.bezier == NONE {
            seg.end.coord
        } else {
            match *self.bezier(seg.end.bezier) {
                [control] => {
                    flags |= MF_CURVE;
                    control
                }
                _ => return,
            }
        };
        // the walk subtracts each distance before the segment (past the end:
        // all): a lone one is the walk's own, whole numbers subtract exactly
        let passed = if over { k + 1 } else { k };
        if over {
            flags |= MF_OVER;
        }
        let mut off = 0.0;
        if passed > 0 {
            flags |= MF_LOWER;
            for j in 0..passed {
                let d = self.segs.at(first + j).distance;
                if passed > 1 && d.fract() != 0.0 {
                    return;
                }
                off += d;
            }
            if !(off < EXACT) {
                return;
            }
        }
        let (step, max, total, last) = (
            p.current_step as f64,
            p.max_steps as f64,
            p.total_distance,
            p.last_distance_reached,
        );
        self.recs.at_mut(path).mslot = slot;
        let m = &mut self.m;
        *m.path.at_mut(slot) = path;
        *m.last.at_mut(slot) = last;
        *m.bits.at_mut(slot >> 6) |= 1 << (slot & 63);
        *m.step.at_mut(slot) = step;
        *m.max.at_mut(slot) = max;
        *m.total.at_mut(slot) = total;
        *m.etab.at_mut(slot) = etab;
        *m.off.at_mut(slot) = off;
        *m.hi.at_mut(slot) = seg.distance;
        *m.flags.at_mut(slot) = flags;
        *m.sx.at_mut(slot) = seg.start.coord.column as f64;
        *m.sy.at_mut(slot) = seg.start.coord.row as f64;
        *m.cx.at_mut(slot) = control.column as f64;
        *m.cy.at_mut(slot) = control.row as f64;
        *m.ex.at_mut(slot) = seg.end.coord.column as f64;
        *m.ey.at_mut(slot) = seg.end.coord.row as f64;
    }

    /// The next step through the slot's mirror: the coordinate; None when
    /// the step is not pure (the mirror is released).
    #[inline(always)]
    fn mirror_step(&mut self, slot: u32) -> Option<Coord> {
        if let Some(s) = self.m.next_step(&self.etab, slot) {
            *self.m.step.at_mut(slot) = s.step;
            *self.m.last.at_mut(slot) = s.d;
            if s.step == *self.m.max.at(slot) {
                // Motion.move's tail reads the record
                self.release(slot);
            }
            return Some(Coord::new(round_half_even(s.x), round_half_even(s.y)));
        }
        self.release(slot);
        None
    }
}

impl Engine {
    /// Motion.paths lookup by name.
    pub fn path_find(&self, slot: u32, name: Name) -> Option<u32> {
        let mut p = self.ch.paths[slot as usize];
        while p != NONE {
            let rec = &self.paths.recs[p as usize];
            if rec.name == name {
                return Some(p);
            }
            p = rec.next;
        }
        None
    }

    /// Motion.new_path. An empty `name` (Name::NONE) asks for the next auto
    /// id: the path count, probing upward past taken ids. A duplicate
    /// explicit id is an error.
    #[allow(clippy::too_many_arguments)]
    pub fn path_new(
        &mut self,
        slot: u32,
        speed: f64,
        ease: Option<Easing>,
        layer: Option<i32>,
        hold_time: i64,
        looping: bool,
        name: Name,
    ) -> Result<u32, String> {
        let name = if name == Name::NONE {
            let mut n = 0;
            let mut p = self.ch.paths[slot as usize];
            while p != NONE {
                n += 1;
                p = self.paths.recs[p as usize].next;
            }
            while self.path_find(slot, Name::auto(n)).is_some() {
                n += 1;
            }
            Name::auto(n)
        } else {
            if self.path_find(slot, name).is_some() {
                return Err(format!("duplicate path id: {}", self.names.to_string(name)));
            }
            name
        };
        if speed <= 0.0 {
            return Err(format!(
                "Path speed must be greater than 0. Received: {speed}"
            ));
        }
        let ease = match ease {
            Some(ease) => match self.paths.eases.iter().position(|&e| e == ease) {
                Some(i) => i as u32,
                None => {
                    self.paths.eases.push(ease);
                    self.paths.eases.len() as u32 - 1
                }
            },
            None => NONE,
        };
        let mut flags = if looping { PF_LOOP } else { 0 };
        if layer.is_some() {
            flags |= PF_LAYER;
        }
        let id = self.paths.recs.len() as u32;
        self.paths.recs.push(Path {
            name,
            next: NONE,
            flags,
            ease,
            layer: layer.unwrap_or(0),
            speed,
            hold: hold_time,
            hold_left: hold_time,
            total_distance: 0.0,
            current_step: 0,
            max_steps: 0,
            last_distance_reached: 0.0,
            origin_distance: 0.0,
            seg_base: NONE,
            seg_count: 0,
            wp_start: 0,
            wp_count: 0,
            etab: 0,
            mslot: NONE,
        });
        let head = self.ch.paths[slot as usize];
        if head == NONE {
            self.ch.paths[slot as usize] = id;
        } else {
            let mut p = head;
            while self.paths.recs[p as usize].next != NONE {
                p = self.paths.recs[p as usize].next;
            }
            self.paths.recs[p as usize].next = id;
        }
        Ok(id)
    }

    /// The path's waypoint called `name`.
    pub fn path_waypoint(&self, path: u32, name: Name) -> Option<Waypoint> {
        let p = &self.paths.recs[path as usize];
        self.paths.wps[p.wp_start as usize..(p.wp_start + p.wp_count) as usize]
            .iter()
            .find(|w| w.name == name)
            .copied()
    }

    /// Path.new_waypoint + _add_waypoint_to_path: from the second waypoint
    /// on, a segment from the previous one, the running total and max_steps.
    /// An empty `name` asks for an auto id (the waypoint count, probing
    /// upward); a duplicate explicit id is an error. Returns the waypoint.
    pub fn path_new_waypoint(
        &mut self,
        path: u32,
        coord: Coord,
        bezier: Option<&[Coord]>,
        name: Name,
    ) -> Result<Waypoint, String> {
        let name = if name == Name::NONE {
            let mut n = self.paths.recs[path as usize].wp_count as usize;
            while self.path_waypoint(path, Name::auto(n)).is_some() {
                n += 1;
            }
            Name::auto(n)
        } else {
            if self.path_waypoint(path, name).is_some() {
                return Err(format!(
                    "duplicate waypoint id: {}",
                    self.names.to_string(name)
                ));
            }
            name
        };
        // Python: an empty control tuple is falsy -> None
        let bezier = match bezier {
            Some(control) if !control.is_empty() => self.paths.intern_bezier(control),
            _ => NONE,
        };
        let waypoint = Waypoint {
            coord,
            name,
            bezier,
        };
        let paths = &mut self.paths;
        paths.unmirror(path);
        let p = &mut paths.recs[path as usize];
        let region_end = paths.wps.len() as u32;
        if p.wp_start + p.wp_count != region_end {
            let (start, count) = (p.wp_start as usize, p.wp_count as usize);
            p.wp_start = region_end;
            paths.wps.extend_from_within(start..start + count);
        }
        paths.wps.push(waypoint);
        p.wp_count += 1;
        if p.wp_count < 2 {
            p.seg_base = paths.segs.len() as u32;
            paths.segs.push(Segment {
                start: waypoint,
                end: waypoint,
                distance: 0.0,
                entered: false,
                exited: false,
            });
            return Ok(waypoint);
        }
        let prev = paths.wps[(p.wp_start + p.wp_count - 2) as usize];
        let distance = paths.distance_to(prev.coord, &waypoint);
        let p = &mut paths.recs[path as usize];
        p.total_distance += distance;
        let block = p.seg_count + 1;
        let region_end = paths.segs.len() as u32;
        if p.seg_base + block != region_end {
            let start = p.seg_base as usize;
            p.seg_base = region_end;
            paths.segs.extend_from_within(start..start + block as usize);
        }
        paths.segs.push(Segment {
            start: prev,
            end: waypoint,
            distance,
            entered: false,
            exited: false,
        });
        p.seg_count += 1;
        p.max_steps = round_half_even(p.total_distance / p.speed);
        p.etab = 0;
        Ok(waypoint)
    }

    /// `path.speed = x`: only the field changes; the next activation or
    /// waypoint recomputes max_steps from it.
    #[inline]
    pub fn path_set_speed(&mut self, path: u32, speed: f64) {
        self.paths.recs[path as usize].speed = speed;
    }

    /// `path.hold_time = x`: only the field changes (hold_time_remaining is
    /// reset on the next activation).
    #[inline]
    pub fn path_set_hold(&mut self, path: u32, hold_time: i64) {
        self.paths.recs[path as usize].hold = hold_time;
    }

    /// Drop the character's path map (`motion.paths.clear()`).
    pub fn paths_clear(&mut self, slot: u32) {
        self.ch.paths[slot as usize] = NONE;
    }

    /// `motion.paths.remove(id)` then `new_path` with the same id and
    /// parameters (rings' "disperse"): the record is emptied in place,
    /// keeping those parameters, so an active reference still names it. (Its
    /// map position is kept, which only auto ids could observe.)
    pub fn path_reset(&mut self, path: u32) {
        self.paths.unmirror(path);
        let p = &mut self.paths.recs[path as usize];
        p.flags &= !PF_ORIGIN;
        p.seg_base = NONE;
        p.seg_count = 0;
        p.wp_start = 0;
        p.wp_count = 0;
        p.total_distance = 0.0;
        p.current_step = 0;
        p.max_steps = 0;
        p.last_distance_reached = 0.0;
        p.origin_distance = 0.0;
        p.hold_left = p.hold;
        p.etab = 0;
    }

    /// Let one single-waypoint path stand in for many (rings' ring paths):
    /// its waypoint moves to `coord` and it takes the distance history
    /// `(total_distance, origin distance)` of the path it plays next (a
    /// path's total drifts by rounding across activations, so each keeps its
    /// own; `(0.0, 0.0)` is never activated). `path_history` reads it back.
    pub fn path_retarget(&mut self, path: u32, coord: Coord, history: (f64, f64)) {
        self.paths.unmirror(path);
        let p = self.paths.recs.at_mut(path);
        debug_assert!(p.wp_count == 1, "path_retarget: not a single-waypoint path");
        p.total_distance = history.0;
        p.origin_distance = history.1;
        self.paths.wps.at_mut(p.wp_start).coord = coord;
    }

    /// The path's `(total_distance, origin distance)` (see `path_retarget`).
    #[inline]
    pub fn path_history(&self, path: u32) -> (f64, f64) {
        let p = self.paths.recs.at(path);
        (p.total_distance, p.origin_distance)
    }

    /// Motion.activate_path: a synthetic origin segment from the current
    /// coordinate to the first waypoint replaces the previous one (rebasing
    /// the total distance), playback restarts, the path's layer applies, and
    /// PATH_ACTIVATED fires.
    pub fn activate_path(&mut self, hooks: &mut dyn Hooks, slot: u32, path: u32) {
        self.doze_wake(slot);
        let current = self.ch.coord[slot as usize];
        let paths = &mut self.paths;
        paths.release(slot);
        paths.unmirror(path);
        let p = &paths.recs[path as usize];
        assert!(
            p.wp_count > 0,
            "activate_path: empty path {}",
            self.names.to_string(p.name)
        );
        let first = paths.wps[p.wp_start as usize];
        let distance = paths.distance_to(current, &first);
        let origin = Waypoint {
            coord: current,
            name: Name::NONE,
            bezier: NONE,
        };
        self.ch.path[slot as usize] = path;
        let p = &mut paths.recs[path as usize];
        p.total_distance += distance;
        if p.flags & PF_ORIGIN != 0 {
            p.total_distance -= p.origin_distance;
        }
        p.flags |= PF_ORIGIN;
        p.origin_distance = distance;
        paths.segs[p.seg_base as usize] = Segment {
            start: origin,
            end: first,
            distance,
            entered: false,
            exited: false,
        };
        p.current_step = 0;
        p.hold_left = p.hold;
        p.max_steps = round_half_even(p.total_distance / p.speed);
        p.etab = 0;
        let (first_seg, count) = p.segs();
        for seg in &mut paths.segs[first_seg as usize..(first_seg + count) as usize] {
            seg.entered = false;
            seg.exited = false;
        }
        let (flags, layer, name) = (p.flags, p.layer, p.name);
        if flags & PF_LAYER != 0 {
            self.set_layer(slot, layer);
        }
        if self.observes(slot, Event::PathActivated) {
            self.handle_event(hooks, slot, Event::PathActivated, Caller::Path(name));
        }
    }

    pub fn activate_path_name(&mut self, hooks: &mut dyn Hooks, slot: u32, name: Name) {
        let path = self
            .path_find(slot, name)
            .expect("activate_path: path not found");
        self.activate_path(hooks, slot, path);
    }

    /// Path.step: the next coordinate. The index-based segment walk re-reads
    /// the path's segments after every event, since a reentrant action may
    /// add waypoints (moving the block) or reactivate the path.
    fn path_step(&mut self, hooks: &mut dyn Hooks, slot: u32, path: u32) -> Coord {
        if *self.paths.m.path.at(slot) == path {
            if let Some(coord) = self.paths.mirror_step(slot) {
                return coord;
            }
        }
        let p = self.paths.recs.at_mut(path);
        if p.max_steps == 0 || p.current_step >= p.max_steps || p.total_distance == 0.0 {
            let (first, count) = p.segs();
            return self.paths.segs[(first + count - 1) as usize].end.coord;
        }
        p.current_step += 1;
        let step = p.current_step;
        let factor = if p.ease == NONE {
            step as f64 / p.max_steps as f64
        } else {
            self.paths.eased_factor(path, step)
        };
        let p = self.paths.recs.at_mut(path);
        let distance_to_travel = factor * p.total_distance;
        p.last_distance_reached = distance_to_travel;
        // in the first segment, entered already: the walk fires nothing
        let (first, _) = p.segs();
        let seg = self.paths.segs.at(first as usize);
        if distance_to_travel <= seg.distance && seg.entered {
            self.paths.mirror(slot, path, 0, false);
            return self.paths.coord_in(path, first, distance_to_travel);
        }
        self.path_walk(hooks, slot, path, distance_to_travel)
    }

    /// Path.step's segment walk from the first segment, with its events.
    #[inline(never)]
    fn path_walk(&mut self, hooks: &mut dyn Hooks, slot: u32, path: u32, distance: f64) -> Coord {
        let mut distance_to_travel = distance;
        let mut active = None;
        // no event fired: the path is as the walk left it
        let mut quiet = true;
        let mut i = 0u32;
        loop {
            let (first, count) = self.paths.recs.at(path).segs();
            if i >= count {
                break;
            }
            let at = (first + i) as usize;
            let seg = *self.paths.segs.at(at);
            if distance_to_travel <= seg.distance {
                active = Some(i);
                if !seg.entered {
                    self.paths.segs.at_mut(at).entered = true;
                    if self.observes(slot, Event::SegmentEntered) {
                        quiet = false;
                        self.handle_event(
                            hooks,
                            slot,
                            Event::SegmentEntered,
                            Caller::Waypoint(seg.end.key()),
                        );
                    }
                }
                break;
            }
            distance_to_travel -= seg.distance;
            if !seg.entered || !seg.exited {
                let observes = self.observes(slot, Event::SegmentEntered)
                    || self.observes(slot, Event::SegmentExited);
                if !observes {
                    let s = self.paths.segs.at_mut(at);
                    s.entered = true;
                    s.exited = true;
                } else {
                    quiet = false;
                    let key = seg.end.key();
                    if !seg.entered {
                        self.paths.segs.at_mut(at).entered = true;
                        self.handle_event(
                            hooks,
                            slot,
                            Event::SegmentEntered,
                            Caller::Waypoint(key),
                        );
                    }
                    if !seg.exited {
                        let (first, _) = self.paths.recs.at(path).segs();
                        self.paths.segs[(first + i) as usize].exited = true;
                        self.handle_event(hooks, slot, Event::SegmentExited, Caller::Waypoint(key));
                    }
                }
            }
            i += 1;
        }
        let p = self.paths.recs.at(path);
        let (first, count) = p.segs();
        // Python for-else: overshoot past the last waypoint re-adds the final
        // segment's distance and travels beyond it (eased overshoot)
        let index = match active {
            Some(index) => {
                if quiet {
                    self.paths.mirror(slot, path, index, false);
                }
                index
            }
            None => {
                let index = count - 1;
                distance_to_travel += self.paths.segs[(first + index) as usize].distance;
                if quiet {
                    self.paths.mirror(slot, path, index, true);
                }
                index
            }
        };
        self.paths.coord_in(path, first + index, distance_to_travel)
    }

    /// Motion.move: step the active path, then holds, loops, completion and
    /// their events. (Motion.previous_coord is not kept: nothing reads it.)
    #[inline(always)]
    pub fn motion_move(&mut self, hooks: &mut dyn Hooks, slot: u32) {
        let path = *self.ch.path.at(slot);
        if path == NONE || self.paths.recs.at(path).segs().1 == 0 {
            return;
        }
        let coord = self.path_step(hooks, slot, path);
        // unchanged: the render cell already matches
        if *self.ch.coord.at(slot) != coord {
            self.set_coordinate(slot, coord);
        }
        self.motion_tail(hooks, slot);
    }

    /// Motion.move after the step: holds, loops, completion and their events.
    #[inline(always)]
    pub(super) fn motion_tail(&mut self, hooks: &mut dyn Hooks, slot: u32) {
        // Python re-reads active_path after the step (a callback may swap it)
        let path = *self.ch.path.at(slot);
        assert!(
            path != NONE,
            "active path cleared mid-move (would be an upstream crash)"
        );
        let p = self.paths.recs.at_mut(path);
        if p.current_step != p.max_steps {
            return;
        }
        if p.hold != 0 && p.hold_left == p.hold {
            let name = p.name;
            if self.observes(slot, Event::PathHolding) {
                self.handle_event(hooks, slot, Event::PathHolding, Caller::Path(name));
            }
            self.paths.recs.at_mut(path).hold_left -= 1;
            return;
        }
        if p.hold_left != 0 {
            p.hold_left -= 1;
            return;
        }
        let name = p.name;
        if p.flags & PF_LOOP != 0 && p.segs().1 > 1 {
            self.deactivate_path(slot, Some(name));
            self.activate_path(hooks, slot, path);
        } else {
            *self.ch.done_path.at_mut(slot) = path;
            self.deactivate_path(slot, Some(name));
            if self.observes(slot, Event::PathComplete) {
                self.handle_event(hooks, slot, Event::PathComplete, Caller::Path(name));
            }
        }
    }

    /// Motion.deactivate_path: any active path, or only the named one.
    pub fn deactivate_path(&mut self, slot: u32, name: Option<Name>) {
        let active = self.ch.path[slot as usize];
        if active == NONE {
            return;
        }
        if name.is_none_or(|n| self.paths.recs[active as usize].name == n) {
            self.doze_wake(slot);
            self.ch.path[slot as usize] = NONE;
            self.paths.release(slot);
            self.mark_candidate(slot);
        }
    }
}
