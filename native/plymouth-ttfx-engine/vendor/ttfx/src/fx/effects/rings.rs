//! rings on the fx engine (old engine: effects/rings.rs).
//!
//! The old engine gives every ring character one single-waypoint path per
//! ring coordinate ("0", "1", ...), chained in a loop. Here one ring path
//! stands in for all of them: playing ring path k points its waypoint at the
//! k-th rotated coordinate and swaps in path k's own distance history
//! (`path_retarget`), stored back after activation. The chain event is a
//! callback that plays k + 1; a condense path resuming ring path k calls
//! back with k. Upstream recreates "disperse" each cycle; here it is emptied
//! in place (`path_reset`). Gradient and disperse frames are memoized by
//! (symbol, final color, ring color).

use std::collections::{HashMap, VecDeque};

use crate::effects::rings::RingsConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym, NONE};
use crate::utils::easing::Easing;
use crate::utils::geometry::{self, Coord};
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::round_half_even;

/// terminal.set_character_visibility(character, False).
const CB_SET_INVISIBLE: u32 = 0;
/// The chain event: ring path k completed, k + 1 (wrapping) plays.
const CB_RING_ADVANCE: u32 = 1;
/// A condense path arrived: ring path `arg` plays.
const CB_RING_PLAY: u32 = 2;

/// character_last_ring_path: a ring path, or an engine path (a condense path
/// that was still active).
#[derive(Debug, Clone, Copy)]
enum Last {
    Ring(u32),
    Path(u32),
}

/// A ring character (RINGCH).
struct RingChar {
    /// The ring's coordinates in its direction, in `Rings::coords`.
    coords: u32,
    n: u32,
    /// character_starting_index.
    start: u32,
    /// The ring path the ring path record plays now.
    cur: u32,
    last: Last,
    /// n (total, origin distance) pairs in `Rings::history`.
    history: u32,
    ring_path: u32,
    disperse_path: u32,
    gradient_scene: u32,
    disperse_scene: u32,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Phase {
    Start,
    Disperse,
    Spin,
    Final,
    Complete,
}

pub struct Rings {
    config: RingsConfig,
    ring_gap: i64,
    /// Every ring's counter-clockwise then clockwise coordinates.
    coords: Vec<Coord>,
    history: Vec<(f64, f64)>,
    ring_chars: Vec<RingChar>,
    /// ring_chars' characters, ring by ring.
    ring_slots: Vec<u32>,
    /// Per slot: its index in ring_chars, NONE for non-ring characters.
    ring_index: Vec<u32>,
    home_path: Vec<u32>,
    non_ring_chars: Vec<u32>,
    phase: Phase,
    initial_disperse_complete: bool,
    spin_time_remaining: i64,
    disperse_time_remaining: i64,
    cycles_remaining: i64,
    initial_phase_time_remaining: i64,
}

impl Rings {
    pub fn new(config: RingsConfig) -> Self {
        Rings {
            config,
            ring_gap: 1,
            coords: Vec::new(),
            history: Vec::new(),
            ring_chars: Vec::new(),
            ring_slots: Vec::new(),
            ring_index: Vec::new(),
            home_path: Vec::new(),
            non_ring_chars: Vec::new(),
            phase: Phase::Start,
            initial_disperse_complete: false,
            spin_time_remaining: 0,
            disperse_time_remaining: 0,
            cycles_remaining: 0,
            initial_phase_time_remaining: 100,
        }
    }

    /// The k-th coordinate of the character's rotated ring (ring path k's
    /// waypoint).
    #[inline]
    fn ring_coord(&self, r: &RingChar, k: u32) -> Coord {
        let mut i = r.start + k;
        if i >= r.n {
            i -= r.n;
        }
        *self.coords.at(r.coords + i)
    }

    /// activate_path(ring path k) through the ring path record.
    fn ring_play(&mut self, e: &mut Engine, slot: u32, k: u32) {
        let index = *self.ring_index.at(slot);
        self.ring_chars.at_mut(index).cur = k;
        let r = self.ring_chars.at(index);
        let (path, h, coord) = (r.ring_path, r.history + k, self.ring_coord(r, k));
        e.path_retarget(path, coord, *self.history.at(h));
        e.activate_path(self, slot, path);
        *self.history.at_mut(h) = e.path_history(path);
    }

    /// Ring.make_disperse_waypoints: five random coordinates of
    /// find_coords_in_rect(origin, ring_gap), then the "disperse" path afresh
    /// with them. Returns the first.
    fn make_disperse_waypoints(&self, e: &mut Engine, path: u32, origin: Coord) -> Coord {
        let gap = self.ring_gap;
        let side = 2 * gap + 1;
        let mut coords = [Coord::new(0, 0); 5];
        for c in &mut coords {
            // find_coords_in_rect is column-major
            let index = e.rng.randrange(0, side * side);
            *c = Coord::new(
                origin.column - gap + index / side,
                origin.row - gap + index % side,
            );
        }
        e.path_reset(path);
        for c in coords {
            e.path_new_waypoint(path, c, None, Name::NONE)
                .expect("fresh waypoint");
        }
        coords[0]
    }

    /// Ring.spin for every ring: a condense path back to the first waypoint
    /// of the last ring path, which resumes on arrival.
    fn spin(&mut self, e: &mut Engine) {
        for i in 0..self.ring_chars.len() {
            let r = &self.ring_chars[i];
            let slot = self.ring_slots[i];
            let (target, action) = match r.last {
                Last::Ring(k) => (
                    self.ring_coord(r, k),
                    Action::Callback(CB_RING_PLAY, k as i64),
                ),
                Last::Path(p) => {
                    // its only waypoint, auto id "0"
                    let first = e
                        .path_waypoint(p, Name::auto(0))
                        .expect("condense waypoint");
                    (
                        first.coord,
                        Action::ActivatePath(e.paths.recs[p as usize].name),
                    )
                }
            };
            let gradient_scene = r.gradient_scene;
            let condense = e
                .path_new(slot, 0.1, None, None, 0, false, Name::NONE)
                .expect("condense path");
            e.path_new_waypoint(condense, target, None, Name::NONE)
                .expect("fresh waypoint");
            let name = e.paths.recs[condense as usize].name;
            e.register_event(slot, Event::PathComplete, Caller::Path(name), action)
                .expect("fresh condense path");
            e.activate_path(self, slot, condense);
            e.activate_scene(self, slot, gradient_scene);
        }
    }

    /// Ring.disperse for every ring: remember the active ring path, then loop
    /// around a fresh disperse path.
    fn disperse(&mut self, e: &mut Engine) {
        for i in 0..self.ring_chars.len() {
            let slot = self.ring_slots[i];
            let r = &self.ring_chars[i];
            let active = e.ch.path[slot as usize];
            let last = if active == NONE {
                Last::Ring(0)
            } else if active == r.ring_path {
                Last::Ring(r.cur)
            } else {
                Last::Path(active)
            };
            let (path, scene) = (r.disperse_path, r.disperse_scene);
            self.ring_chars[i].last = last;
            let origin = e.coord(slot);
            self.make_disperse_waypoints(e, path, origin);
            e.activate_path(self, slot, path);
            e.activate_scene(self, slot, scene);
        }
    }

    /// The initial disperse: every ring character heads (eased) to the first
    /// waypoint of a fresh disperse path around its ring start, which then
    /// loops; the other characters leave the canvas.
    fn initial_disperse(&mut self, e: &mut Engine) {
        for i in 0..self.ring_chars.len() {
            let slot = self.ring_slots[i];
            let r = &self.ring_chars[i];
            let ring_start = self.ring_coord(r, 0);
            let (path, scene) = (r.disperse_path, r.disperse_scene);
            let first = self.make_disperse_waypoints(e, path, ring_start);
            let initial = e
                .path_new(
                    slot,
                    0.3,
                    Some(Easing::OutCubic),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .expect("initial path");
            e.path_new_waypoint(initial, first, None, Name::NONE)
                .expect("fresh waypoint");
            let (name, disperse) = (
                e.paths.recs[initial as usize].name,
                e.paths.recs[path as usize].name,
            );
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(name),
                Action::ActivatePath(disperse),
            )
            .expect("fresh initial path");
            e.activate_scene(self, slot, scene);
            e.activate_path(self, slot, initial);
            e.active_insert(slot);
        }
        let external = e.name("external");
        for i in 0..self.non_ring_chars.len() {
            let slot = self.non_ring_chars[i];
            e.activate_path_name(self, slot, external);
            e.active_insert(slot);
        }
    }

    /// Everyone visible and home; ring characters fade back.
    fn final_phase(&mut self, e: &mut Engine) {
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            e.set_visible(slot, true);
            let home = self.home_path[slot as usize];
            e.activate_path(self, slot, home);
            e.active_insert(slot);
            let index = self.ring_index[slot as usize];
            if index == NONE {
                continue;
            }
            let scene = self.ring_chars[index as usize].disperse_scene;
            e.activate_scene(self, slot, scene);
        }
    }
}

impl Hooks for Rings {
    fn callback(&mut self, e: &mut Engine, slot: u32, id: u32, arg: i64) {
        match id {
            CB_SET_INVISIBLE => e.set_visible(slot, false),
            CB_RING_ADVANCE => {
                let r = self.ring_chars.at(*self.ring_index.at(slot));
                let mut k = r.cur + 1;
                if k >= r.n {
                    k = 0;
                }
                self.ring_play(e, slot, k);
            }
            _ => self.ring_play(e, slot, arg as u32),
        }
    }
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

/// A ring character's gradient scene (final color -> ring color, 3 ticks per
/// color) or disperse scene (ring color -> final color, 10 ticks): the final
/// colors for one tick when dynamic, else the 8-step gradient.
fn ring_scene_frames(
    e: &mut Engine,
    memo: &mut HashMap<(bool, Sym, Color, Color), Vec<Frame>, FxBuild>,
    scene: u32,
    slot: u32,
    colors: ColorPair,
    ring_color: Color,
    disperse: bool,
) -> Result<(), EngineError> {
    let sym = e.input_sym(slot);
    if e.existing_color_handling() == ExistingColorHandling::Dynamic {
        return e.add_frame(scene, sym, 1, Some(colors), 0).map_err(other);
    }
    let final_fg = colors.fg_color.expect("gradient mapping fg");
    let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
    let key = (disperse, sym, final_fg, ring_color);
    match memo.get(&key) {
        Some(frames) if plain => e.append_frames(scene, frames),
        _ => {
            let (stops, duration) = if disperse {
                ([ring_color, final_fg], 10)
            } else {
                ([final_fg, ring_color], 3)
            };
            let spectrum = Gradient::with_steps(&stops, 8, false)
                .map_err(other)?
                .spectrum;
            e.apply_gradient(scene, &[sym], duration, Some(&spectrum), None)
                .map_err(other)?;
            if plain {
                memo.insert(key, e.scenes.frames_of(scene).to_vec());
            }
        }
    }
    Ok(())
}

impl Effect for Rings {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let canvas = e.canvas.clone();
        // ring_gap = int(max(round(min(top, right) * config.ring_gap), 1))
        self.ring_gap =
            round_half_even(canvas.top.min(canvas.right) as f64 * config.ring_gap).max(1);
        let final_gradient = Gradient::new(
            &config.final_gradient_stops,
            &config.final_gradient_steps,
            false,
            false,
        )
        .map_err(other)?;
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
        let home = e.name("home");
        let external = e.name("external");
        let ring = e.name("ring");
        let disperse = e.name("disperse");
        let gradient = e.name("gradient");
        let slots = e.char_count();
        self.ring_index = vec![NONE; slots];
        self.home_path = vec![NONE; slots];

        // character_final_color_map
        let mut final_colors = vec![ColorPair::default(); slots];
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for &slot in &characters {
            let colors = if dynamic {
                ColorPair::new(e.input_fg(slot), e.input_bg(slot))
            } else {
                let input = e.input_coord(slot);
                ColorPair::new(
                    Some(
                        *final_gradient_mapping
                            .get(&input)
                            .expect("gradient mapping fg"),
                    ),
                    None,
                )
            };
            final_colors[slot as usize] = colors;
            let scene = e.scene_new(slot, Name::NONE, false, None, None);
            e.add_frame(scene, e.input_sym(slot), 1, Some(colors), 0)
                .map_err(other)?;
            let path = e
                .path_new(slot, 0.8, Some(Easing::OutQuad), None, 0, false, home)
                .map_err(other)?;
            e.path_new_waypoint(path, e.input_coord(slot), None, Name::NONE)
                .map_err(other)?;
            self.home_path[slot as usize] = path;
            e.activate_scene(self, slot, scene);
            e.set_visible(slot, true);
        }
        let mut pending = characters;
        e.rng.shuffle(&mut pending);

        // make rings: (coordinate offset, count, color, rotation speed)
        let mut rings: Vec<(u32, u32, Color, f64)> = Vec::new();
        let center = canvas.center;
        let radius_limit = canvas.right.max(canvas.top);
        let mut radius = 1;
        while radius < radius_limit {
            let ring_coords = geometry::find_coords_on_circle(center, radius, 7 * radius, true);
            let in_canvas = ring_coords
                .iter()
                .filter(|&&c| canvas.coord_is_in_canvas(c))
                .count();
            if (in_canvas as f64) / (ring_coords.len() as f64) < 0.25 {
                break;
            }
            let color = config.ring_colors[rings.len() % config.ring_colors.len()];
            // Ring.__init__: rotation_speed
            let speed = e.rng.uniform(config.spin_speed.0, config.spin_speed.1);
            rings.push((
                self.coords.len() as u32,
                ring_coords.len() as u32,
                color,
                speed,
            ));
            self.coords.extend(&ring_coords);
            self.coords.extend(ring_coords.iter().rev());
            radius += self.ring_gap;
        }

        // assign characters to rings, alternating directions
        // (kind, symbol, final color, ring color) -> a plain scene's frames
        let mut memo: HashMap<(bool, Sym, Color, Color), Vec<Frame>, FxBuild> = HashMap::default();
        let mut pending: VecDeque<u32> = pending.into();
        let mut history = 0u32;
        for (ring_count, &(offset, n, color, speed)) in rings.iter().enumerate() {
            let clockwise = ring_count % 2 == 1;
            for start in 0..n {
                let Some(slot) = pending.pop_front() else {
                    break;
                };
                // Ring.add_character: gradient scene, the ring paths and their
                // chain, disperse scene
                let colors = final_colors[slot as usize];
                let gradient_scene = e.scene_new(slot, gradient, false, None, None);
                ring_scene_frames(e, &mut memo, gradient_scene, slot, colors, color, false)?;
                let coords = offset + if clockwise { n } else { 0 };
                let ring_path = e
                    .path_new(slot, speed, None, None, 0, false, ring)
                    .map_err(other)?;
                e.path_new_waypoint(
                    ring_path,
                    self.coords[(coords + start) as usize],
                    None,
                    Name::NONE,
                )
                .map_err(other)?;
                let disperse_scene = e.scene_new(slot, disperse, false, None, None);
                ring_scene_frames(e, &mut memo, disperse_scene, slot, colors, color, true)?;
                let disperse_path = e
                    .path_new(slot, 0.14, None, None, 0, true, disperse)
                    .map_err(other)?;
                if n >= 2 {
                    e.register_event(
                        slot,
                        Event::PathComplete,
                        Caller::Path(ring),
                        Action::Callback(CB_RING_ADVANCE, 0),
                    )
                    .map_err(other)?;
                }
                self.ring_index[slot as usize] = self.ring_chars.len() as u32;
                self.ring_slots.push(slot);
                self.ring_chars.push(RingChar {
                    coords,
                    n,
                    start,
                    cur: 0,
                    last: Last::Ring(0),
                    history,
                    ring_path,
                    disperse_path,
                    gradient_scene,
                    disperse_scene,
                });
                history += n;
            }
        }
        self.history = vec![(0.0, 0.0); history as usize];

        // make external waypoints for characters not in rings
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            if self.ring_index[slot as usize] != NONE {
                continue;
            }
            let external_coord = canvas.random_coord(&mut e.rng, true, false);
            let path = e
                .path_new(slot, 0.8, Some(Easing::OutSine), None, 0, false, external)
                .map_err(other)?;
            e.path_new_waypoint(path, external_coord, None, Name::NONE)
                .map_err(other)?;
            self.non_ring_chars.push(slot);
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(external),
                Action::Callback(CB_SET_INVISIBLE, 0),
            )
            .map_err(other)?;
        }
        self.phase = Phase::Start;
        self.initial_disperse_complete = false;
        self.spin_time_remaining = config.spin_duration;
        self.disperse_time_remaining = config.disperse_duration;
        self.cycles_remaining = config.spin_disperse_cycles;
        self.initial_phase_time_remaining = 100;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        match self.phase {
            Phase::Complete => return false,
            Phase::Start => {
                if self.initial_phase_time_remaining == 0 {
                    self.phase = Phase::Disperse;
                } else {
                    self.initial_phase_time_remaining -= 1;
                }
            }
            Phase::Disperse => {
                if !self.initial_disperse_complete {
                    self.initial_disperse_complete = true;
                    self.initial_disperse(e);
                } else if self.disperse_time_remaining == 0 {
                    self.phase = Phase::Spin;
                    self.cycles_remaining -= 1;
                    self.spin_time_remaining = self.config.spin_duration;
                    self.spin(e);
                } else {
                    self.disperse_time_remaining -= 1;
                }
            }
            Phase::Spin => {
                if self.spin_time_remaining == 0 {
                    if self.cycles_remaining == 0 {
                        self.phase = Phase::Final;
                        self.final_phase(e);
                    } else {
                        self.disperse_time_remaining = self.config.disperse_duration;
                        self.disperse(e);
                        self.phase = Phase::Disperse;
                    }
                } else {
                    self.spin_time_remaining -= 1;
                }
            }
            Phase::Final => {
                if e.active_is_empty() {
                    self.phase = Phase::Complete;
                }
            }
        }
        e.update(self);
        true
    }
}
