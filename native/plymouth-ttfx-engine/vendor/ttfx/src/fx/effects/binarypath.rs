//! binarypath on the fx engine (old engine: effects/binarypath.rs).
//!
//! Every input character gets a representation: its code point's bits (at
//! least 8) as added characters in consecutive slots.
//!
//! A bit's color scene is one frame of duration 1: it only sets the visual,
//! which the bit keeps, and completes on the bit's first tick, before its
//! path can end. So a bit gets its visual directly and no scene.
//!
//! A representation's bits walk one path (same waypoints and start, so the
//! same origin segment); bit k is released k frames after bit 0 and ticks
//! until its path ends, so its coordinate after a tick is bit k-1's before
//! it. So only bit 0 walks the segments (Path.step's arithmetic) and bits
//! get no engine path. Nothing else observes a bit's path or scene: a bit is
//! active exactly while its path is (`moving`), read only by the emptiness
//! test. Collapse and brighten frames are memoized by (symbol, final color).

use std::collections::HashMap;

use crate::effects::binarypath::BinaryPathConfig;
use crate::engine::animation::{Animation, ExistingColorHandling};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterGroup, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::easing::Easing;
use crate::utils::geometry::{self, Coord};
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::round_half_even;

/// _BinaryRepresentation: the source character, its bits (slots `first..
/// first + count`) and how many of them are on their way.
#[derive(Clone, Copy)]
struct Rep {
    source: u32,
    first: u32,
    count: u32,
    emitted: u32,
    input_coord: Coord,
    /// The path's segments (`segs[seg..seg + seg_count]`), its total
    /// distance and max_steps, and bit 0's ticks (its current_step until its
    /// path ends).
    seg: u32,
    seg_count: u32,
    total: f64,
    max_steps: i64,
    step: i64,
    /// The walk's cursor: the segments before `cur` are passed for good
    /// (the distance only grows), `passed` their total.
    cur: u32,
    passed: f64,
}

type SourceFrames = (Vec<Frame>, Vec<Frame>);

#[derive(Clone, Copy)]
struct Seg {
    start: Coord,
    end: Coord,
    distance: f64,
}

pub struct BinaryPath {
    config: BinaryPathConfig,
    reps: Vec<Rep>,
    segs: Vec<Seg>,
    /// The representations with a bit still on its path.
    moving: Vec<u32>,
    /// Indexes into `reps`, in the old engine's list order.
    pending: Vec<u32>,
    active: Vec<u32>,
    wipe_groups: Vec<Vec<u32>>,
    wipe_pos: usize,
    wipe: bool,
    complete: bool,
    last_frame_provided: bool,
    max_active: usize,
    collapse: Name,
    brighten: Name,
}

impl BinaryPath {
    pub fn new(config: BinaryPathConfig) -> Self {
        BinaryPath {
            config,
            reps: Vec::new(),
            segs: Vec::new(),
            moving: Vec::new(),
            pending: Vec::new(),
            active: Vec::new(),
            wipe_groups: Vec::new(),
            wipe_pos: 0,
            wipe: false,
            complete: false,
            last_frame_provided: false,
            max_active: 0,
            collapse: Name::NONE,
            brighten: Name::NONE,
        }
    }
}

impl Hooks for BinaryPath {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// The alternating row/column walk from a random start outside the canvas to
/// `input`, with the two duplicate terminal waypoints.
fn make_coords(e: &mut Engine, input: Coord, coords: &mut Vec<Coord>) {
    coords.clear();
    let start = e.canvas.random_coord(&mut e.rng, true, false);
    coords.push(start);
    // choice(["col", "row"])
    let mut row_next = e.rng.choice_index(2) == 0;
    let row_limit = 10.max((e.canvas.right as f64 * 0.2) as i64);
    let mut next = start;
    let mut last = start;
    while last != input {
        let row_distance = (last.row - input.row).abs();
        let column_distance = (last.column - input.column).abs();
        if row_next && row_distance > 0 {
            let step = e.rng.randint(1, row_distance.min(row_limit));
            next = Coord::new(
                last.column,
                last.row + step * (input.row - last.row).signum(),
            );
            row_next = false;
        } else if !row_next && column_distance > 0 {
            let step = e.rng.randint(1, column_distance.min(4));
            next = Coord::new(
                last.column + step * (input.column - last.column).signum(),
                last.row,
            );
            row_next = true;
        } else {
            next = input;
        }
        coords.push(next);
        last = next;
    }
    coords.push(next);
    coords.push(input);
}

impl BinaryPath {
    /// Path.step for bit 0 at `rep.step` (a bit has no segment events).
    /// Every segment is a row or a column, so its distance is an integer and
    /// subtracting them one by one from the distance to travel is exact: the
    /// walk resumes at the cursor with the passed total subtracted at once.
    #[inline]
    fn position(segs: &[Seg], rep: &mut Rep) -> Coord {
        let segs = &segs[rep.seg as usize..(rep.seg + rep.seg_count) as usize];
        if rep.max_steps == 0 {
            return segs[segs.len() - 1].end;
        }
        let mut distance_to_travel =
            rep.step as f64 / rep.max_steps as f64 * rep.total - rep.passed;
        let mut index = segs.len() - 1;
        let mut found = false;
        for i in rep.cur as usize..segs.len() {
            // in bounds: the loop's range
            let seg = segs.at(i);
            if distance_to_travel <= seg.distance {
                index = i;
                found = true;
                break;
            }
            distance_to_travel -= seg.distance;
            rep.passed += seg.distance;
            rep.cur = i as u32 + 1;
        }
        // checked: len() - 1 wraps on a path without segments
        let seg = segs[index];
        if !found {
            // for-else: overshoot re-adds the final segment's distance
            distance_to_travel += seg.distance;
        }
        let t = if seg.distance == 0.0 {
            0.0
        } else {
            (distance_to_travel / seg.distance).min(1.0)
        };
        geometry::find_coord_on_line(seg.start, seg.end, t)
    }

    /// The bits' ticks: each released bit on its path takes the coordinate
    /// of the bit ahead, and bit 0 steps. A representation stops moving when
    /// its last bit's path ends (after max(max_steps, 1) ticks).
    fn move_bits(&mut self, e: &mut Engine) {
        let mut kept = 0;
        for k in 0..self.moving.len() {
            let r = *self.moving.at(k);
            let rep = self.reps[r as usize];
            // the representation's bit slots, checked once for the whole
            // shift below (the hot loop: every bit of every moving rep)
            assert!((rep.first + rep.emitted) as usize <= e.ch.len());
            for slot in (rep.first + 1..rep.first + rep.emitted).rev() {
                let ahead = *e.ch.coord.at(slot - 1);
                if *e.ch.coord.at(slot) != ahead {
                    e.set_coordinate(slot, ahead);
                }
            }
            let ticks = rep.max_steps.max(1);
            // bit 0's ticks, counted on past its path's end
            let rep_mut = self.reps.at_mut(r);
            rep_mut.step += 1;
            if rep.step < ticks {
                let coord = Self::position(&self.segs, rep_mut);
                if e.ch.coord[rep.first as usize] != coord {
                    e.set_coordinate(rep.first, coord);
                }
            }
            let rep = self.reps.at(r);
            if rep.emitted < rep.count || rep.step - ((rep.count - 1) as i64) < ticks {
                *self.moving.at_mut(kept) = r;
                kept += 1;
            }
        }
        self.moving.truncate(kept);
    }
}

impl Effect for BinaryPath {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        // __init__: final_wipe_chars computed before build()
        self.wipe_groups = e.get_characters_grouped(
            CharacterFilter::default(),
            CharacterGroup::DiagonalTopRightToBottomLeft,
        );
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
        let canvas = &e.canvas;
        let final_gradient_mapping = final_gradient
            .build_coordinate_color_mapping(
                canvas.text_bottom,
                canvas.text_top,
                canvas.text_left,
                canvas.text_right,
                config.final_gradient_direction,
            )
            .map_err(other)?;
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );

        // the bits: format(ord(symbol), "08b")
        let digits = [e.sym("0"), e.sym("1")];
        self.reps.reserve(characters.len());
        for &slot in &characters {
            let symbol = e.symbol(e.input_sym(slot));
            let code_point = symbol.chars().next().expect("empty symbol") as u32;
            let count = 32 - (code_point | 0x80).leading_zeros();
            let mut first = 0;
            for bit in (0..count).rev() {
                let added =
                    e.add_character_sym(digits[(code_point >> bit & 1) as usize], Coord::new(0, 0));
                if bit == count - 1 {
                    first = added;
                }
            }
            self.reps.push(Rep {
                source: slot,
                first,
                count,
                emitted: 0,
                input_coord: e.input_coord(slot),
                seg: 0,
                seg_count: 0,
                total: 0.0,
                max_steps: 0,
                step: 0,
                cur: 0,
                passed: 0.0,
            });
        }

        // (digit, color) -> the bit's visual
        let colors = &config.binary_colors;
        let mut bit_visuals = Vec::with_capacity(colors.len() * 2);
        for &sym in &digits {
            for &color in colors {
                let info = VisualInfo {
                    sym,
                    fg: Some(color),
                    bg: None,
                    attrs: HAS_COLORS,
                };
                bit_visuals.push(e.visuals.make(&e.symbols, info));
            }
        }
        let mut coords = Vec::new();
        for r in 0..self.reps.len() {
            let (first, count) = (self.reps[r].first, self.reps[r].count);
            make_coords(e, self.reps[r].input_coord, &mut coords);
            // activation's origin segment (the bits start on the first
            // waypoint), then Path.new_waypoint's segments and running total
            let seg = self.segs.len() as u32;
            self.segs.push(Seg {
                start: coords[0],
                end: coords[0],
                distance: 0.0,
            });
            let mut total = 0.0;
            for pair in coords.windows(2) {
                let distance = geometry::find_length_of_line(pair[0], pair[1], true);
                debug_assert!(
                    distance.fract() == 0.0,
                    "binarypath: segment off a row or column"
                );
                total += distance;
                self.segs.push(Seg {
                    start: pair[0],
                    end: pair[1],
                    distance,
                });
            }
            let rep = &mut self.reps[r];
            rep.seg = seg;
            rep.seg_count = coords.len() as u32;
            rep.total = total;
            rep.max_steps = round_half_even(total / config.movement_speed);
            for slot in first..first + count {
                e.set_coordinate(slot, coords[0]);
                e.set_layer(slot, 1);
                let color = e.rng.choice_index(colors.len());
                let digit = (e.input_sym(slot) == digits[1]) as usize;
                e.set_visual(slot, bit_visuals[digit * colors.len() + color]);
            }
        }

        self.collapse = e.name("collapse_scn");
        self.brighten = e.name("brighten_scn");
        let white = Color::from_hex("ffffff").unwrap();
        let spectrum = |a: Color, b: Color, steps: i64| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[a, b], steps, false)
                .map_err(other)?
                .spectrum)
        };
        let dim = |c: Color| Animation::adjust_color_brightness(&c, 0.5);
        // final color -> its index; (symbol, final color) -> the collapse and
        // brighten frames of plain scenes
        let mut final_index: HashMap<Color, u32, FxBuild> = HashMap::default();
        let mut memo: HashMap<(Sym, u32), SourceFrames, FxBuild> = HashMap::default();
        for &slot in &characters {
            let sym = e.input_sym(slot);
            let collapse = e.scene_new(slot, self.collapse, false, None, Some(Easing::InQuad));
            let (final_fg, final_bg) = if dynamic {
                (e.input_fg(slot), e.input_bg(slot))
            } else {
                (
                    Some(*final_gradient_mapping.get(&e.input_coord(slot)).unwrap()),
                    None,
                )
            };
            if !dynamic {
                let final_fg = final_fg.unwrap();
                let next_index = final_index.len() as u32;
                let index = *final_index.entry(final_fg).or_insert(next_index);
                let plain = e.scene(collapse).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                if plain {
                    if let Some((collapse_frames, brighten_frames)) = memo.get(&(sym, index)) {
                        e.append_frames(collapse, collapse_frames);
                        let brighten = e.scene_new(slot, self.brighten, false, None, None);
                        e.append_frames(brighten, brighten_frames);
                        continue;
                    }
                }
                let dim_fg = dim(final_fg);
                e.apply_gradient(
                    collapse,
                    &[sym],
                    3,
                    Some(&spectrum(white, dim_fg, 7)?),
                    None,
                )
                .map_err(other)?;
                let brighten = e.scene_new(slot, self.brighten, false, None, None);
                e.apply_gradient(
                    brighten,
                    &[sym],
                    2,
                    Some(&spectrum(dim_fg, final_fg, 10)?),
                    None,
                )
                .map_err(other)?;
                if plain {
                    let frames = (
                        e.scenes.frames_of(collapse).to_vec(),
                        e.scenes.frames_of(brighten).to_vec(),
                    );
                    memo.insert((sym, index), frames);
                }
                continue;
            }
            let (dim_fg, dim_bg) = (final_fg.map(dim), final_bg.map(dim));
            let collapse_fg = dim_fg.map(|c| spectrum(white, c, 7)).transpose()?;
            let collapse_bg = dim_bg.map(|c| spectrum(white, c, 7)).transpose()?;
            if collapse_fg.is_some() || collapse_bg.is_some() {
                e.apply_gradient(
                    collapse,
                    &[sym],
                    3,
                    collapse_fg.as_deref(),
                    collapse_bg.as_deref(),
                )
                .map_err(other)?;
            } else {
                e.add_frame(collapse, sym, 3, Some(ColorPair::default()), 0)
                    .map_err(other)?;
            }
            let brighten = e.scene_new(slot, self.brighten, false, None, None);
            let brighten_fg = dim_fg
                .zip(final_fg)
                .map(|(d, f)| spectrum(d, f, 10))
                .transpose()?;
            let brighten_bg = dim_bg
                .zip(final_bg)
                .map(|(d, f)| spectrum(d, f, 10))
                .transpose()?;
            if brighten_fg.is_some() || brighten_bg.is_some() {
                e.apply_gradient(
                    brighten,
                    &[sym],
                    2,
                    brighten_fg.as_deref(),
                    brighten_bg.as_deref(),
                )
                .map_err(other)?;
            } else {
                e.add_frame(brighten, sym, 2, Some(ColorPair::default()), 0)
                    .map_err(other)?;
            }
        }
        self.max_active =
            1.max((config.active_binary_groups * self.reps.len() as f64) as i64) as usize;
        self.pending = (0..self.reps.len() as u32).collect();
        self.active = Vec::with_capacity(self.max_active.min(self.reps.len()));
        self.moving = Vec::with_capacity(self.reps.len());
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.complete && e.active_is_empty() && self.moving.is_empty() {
            if self.last_frame_provided {
                return false;
            }
            self.last_frame_provided = true;
            return true;
        }
        if !self.wipe {
            while self.active.len() < self.max_active && !self.pending.is_empty() {
                let index = e.rng.randrange(0, self.pending.len() as i64) as usize;
                let r = self.pending.remove(index);
                self.active.push(r);
                self.moving.push(r);
            }
            let mut kept = 0;
            for k in 0..self.active.len() {
                let r = *self.active.at(k);
                let rep = self.reps.at_mut(r);
                if rep.emitted < rep.count {
                    let slot = rep.first + rep.emitted;
                    rep.emitted += 1;
                    e.set_visible(slot, true);
                } else if (rep.first..rep.first + rep.count)
                    .all(|s| *e.ch.coord.at(s) == rep.input_coord)
                {
                    let rep = *rep;
                    for slot in rep.first..rep.first + rep.count {
                        e.set_visible(slot, false);
                    }
                    e.set_visible(rep.source, true);
                    let collapse = self.collapse;
                    e.activate_scene_name(self, rep.source, collapse);
                    e.active_insert(rep.source);
                    continue;
                }
                *self.active.at_mut(kept) = r;
                kept += 1;
            }
            self.active.truncate(kept);
            if e.active_is_empty() && self.moving.is_empty() {
                self.wipe = true;
            }
        }
        if self.wipe {
            for _ in 0..2 {
                if self.wipe_pos < self.wipe_groups.len() {
                    let group = std::mem::take(&mut self.wipe_groups[self.wipe_pos]);
                    self.wipe_pos += 1;
                    let brighten = self.brighten;
                    for &slot in &group {
                        e.activate_scene_name(self, slot, brighten);
                        e.set_visible(slot, true);
                        e.active_insert(slot);
                    }
                } else {
                    self.complete = true;
                }
            }
        }
        self.move_bits(e);
        e.update(self);
        true
    }
}
