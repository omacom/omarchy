//! swarm on the fx engine (old engine: effects/swarm.rs).
//!
//! Characters are cut into swarms (consecutive runs of the top-to-bottom,
//! left-to-right order); swarms launch from the end. Each character of a swarm
//! gets, per swarm area a, a path "{a}_swarm_area" (flash scene "0" and layer 1
//! while it runs) and two inner paths named by the path count (3a + 1, 3a + 2),
//! then a landing path (auto id 3k) whose completion plays the landing scene
//! "1"; the paths are chained in that order. The first character of the
//! current swarm to reach a later area (by the leading digit of its name) leads
//! the others there. A character's paths are made in one run, so its area a
//! is path `first + 3a` and the leader test is arithmetic on the active path
//! id.
//!
//! Upstream's find_coords_on_circle is lru_cached and swarm shuffles the list
//! it returns in place, so a repeated focus coordinate sees the shuffled list:
//! the circle cache keeps one list per coordinate for the run (with the pure
//! find_coords_in_circle alongside). A flash scene's frames are memoized per
//! swarm by symbol, a landing scene's by (symbol, final color).

use std::collections::hash_map::Entry;
use std::collections::HashMap;

use crate::effects::swarm::SwarmConfig;
use crate::engine::animation::{ExistingColorHandling, SyncMetric};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::easing::Easing;
use crate::utils::geometry::{self, Coord};
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::{floor_div, round_half_even};

const FLASH_SCENE: Name = Name(0);
const LAND_SCENE: Name = Name(1);

/// One circle cache entry: find_coords_on_circle (shuffled in place across
/// the run) and find_coords_in_circle of the same focus coordinate.
struct Circle {
    on: Vec<Coord>,
    inside: Vec<Coord>,
}

pub struct Swarm {
    config: SwarmConfig,
    /// The characters in swarm order, and each one's first path (its area 0);
    /// swarm j is `bounds[j]` of them, with `areas[j]` swarm areas.
    order: Vec<u32>,
    first_path: Vec<u32>,
    bounds: Vec<(usize, usize)>,
    areas: Vec<u32>,
    /// Swarms not launched yet (they launch from the end).
    pending: usize,
    /// The current swarm's range in `order` and its area count.
    current: (usize, usize),
    current_areas: u32,
    call_next: bool,
    /// int(active_swarm_area[0]).
    active_digit: u8,
    /// Leading decimal digit of each area index.
    digits: Vec<u8>,
}

impl Swarm {
    pub fn new(config: SwarmConfig) -> Self {
        Swarm {
            config,
            order: Vec::new(),
            first_path: Vec::new(),
            bounds: Vec::new(),
            areas: Vec::new(),
            pending: 0,
            current: (0, 0),
            current_areas: 0,
            call_next: true,
            active_digit: 0,
            digits: Vec::new(),
        }
    }

    /// SwarmIterator.make_swarms: swarms pop off the end of the
    /// bottom-to-top, right-to-left list, so the order is that list reversed
    /// and cut into runs of `size`; a final run shorter than size // 2 joins
    /// the one before.
    fn make_swarms(&mut self, e: &mut Engine, size: i64) {
        let mut order = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::BottomToTopRightToLeft,
        );
        order.reverse();
        let size = size as usize;
        let mut bounds: Vec<(usize, usize)> = (0..order.len())
            .step_by(size)
            .map(|start| (start, (start + size).min(order.len())))
            .collect();
        let (start, end) = bounds.pop().expect("make_swarms: no swarms");
        if ((end - start) as i64) < floor_div(size as i64, 2) {
            bounds
                .last_mut()
                .expect("upstream IndexError: no preceding swarm to merge into")
                .1 = end;
        } else {
            bounds.push((start, end));
        }
        self.order = order;
        self.bounds = bounds;
    }
}

fn leading_digit(mut n: usize) -> u8 {
    while n >= 10 {
        n /= 10;
    }
    n as u8
}

impl Hooks for Swarm {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Swarm {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        // SwarmIterator.DYNAMIC_CLEAR_COLOR
        let dynamic_clear_color = Color::from_hex("#ffffff").unwrap();
        let flash = config.flash_color;
        let count = e
            .get_characters(
                CharacterFilter::default(),
                CharacterSort::TopToBottomLeftToRight,
            )
            .len();
        let swarm_size = round_half_even(count as f64 * config.swarm_size).max(1);
        self.make_swarms(e, swarm_size);
        let canvas = e.canvas.clone();
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
        let radius = (floor_div(canvas.right.min(canvas.top), 2)).max(1);
        let diameter = (floor_div(canvas.right.min(canvas.top), 6)).max(1) * 2;
        let flash_spectrum = |c: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[flash, c], 10, false)
                .map_err(other)?
                .spectrum)
        };

        let mut circles: Vec<Circle> = Vec::new();
        let mut circle_index: HashMap<Coord, u32, FxBuild> = HashMap::default();
        // (key coordinate, circle) of the current swarm's area map
        let mut areas: Vec<(Coord, u32)> = Vec::new();
        let mut area_names: Vec<Name> = Vec::new();
        let mut chain: Vec<Name> = Vec::new();
        // input symbol -> the flash frames of the current swarm
        let mut flash_memo: HashMap<Sym, Vec<Frame>, FxBuild> = HashMap::default();
        let mut mirror: Vec<Color> = Vec::new();
        // final color -> its landing spectrum; (symbol, final color) -> frames
        let mut land_spectra: HashMap<Color, Vec<Color>, FxBuild> = HashMap::default();
        let mut land_memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();

        let bounds = std::mem::take(&mut self.bounds);
        let order = std::mem::take(&mut self.order);
        for &(start, end) in &bounds {
            let base = config.base_color[e.rng.choice_index(config.base_color.len())];
            let swarm_gradient = Gradient::with_steps(&[base, flash], 7, false).map_err(other)?;
            mirror.clear();
            mirror.extend_from_slice(&swarm_gradient.spectrum);
            mirror.extend(std::iter::repeat_n(flash, 10));
            mirror.extend(swarm_gradient.spectrum.iter().rev());
            flash_memo.clear();

            let spawn = canvas.random_coord(&mut e.rng, true, false);
            let area_count = e.rng.randint(
                config.swarm_area_count_range.0,
                config.swarm_area_count_range.1,
            );
            areas.clear();
            let mut last_focus = spawn;
            let mut made = 0;
            while made < area_count {
                let circle = match circle_index.get(&last_focus) {
                    Some(&c) => c,
                    None => {
                        let c = circles.len() as u32;
                        circles.push(Circle {
                            on: geometry::find_coords_on_circle(last_focus, radius, 0, true),
                            inside: geometry::find_coords_in_circle(last_focus, diameter),
                        });
                        circle_index.insert(last_focus, c);
                        c
                    }
                };
                let on = &mut circles[circle as usize].on;
                e.rng.shuffle(on);
                let next_focus = match on.iter().find(|&&c| canvas.coord_is_in_canvas(c)) {
                    Some(&c) => c,
                    None => canvas.random_coord(&mut e.rng, false, false),
                };
                made += 1;
                // dict assignment: a repeated key keeps its position (and
                // gets the same list)
                if !areas.iter().any(|&(key, _)| key == last_focus) {
                    areas.push((last_focus, circle));
                }
                last_focus = next_focus;
            }
            while area_names.len() < areas.len() {
                let a = area_names.len();
                area_names.push(e.name(&format!("{a}_swarm_area")));
                self.digits.push(leading_digit(a));
            }
            self.areas.push(areas.len() as u32);
            // path names in insertion order, for chain_paths
            chain.clear();
            for (a, &name) in area_names[..areas.len()].iter().enumerate() {
                chain.extend([name, Name::auto(3 * a + 1), Name::auto(3 * a + 2)]);
            }
            let landing = Name::auto(3 * areas.len());
            chain.push(landing);

            for &slot in &order[start..end] {
                let sym = e.input_sym(slot);
                let input = e.input_coord(slot);
                e.set_coordinate(slot, spawn);
                self.first_path.push(e.paths.recs.len() as u32);
                let flash_scene =
                    e.scene_new(slot, Name::NONE, false, Some(SyncMetric::Distance), None);
                let plain = e.scene(flash_scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match flash_memo.get(&sym) {
                    Some(frames) if plain => e.append_frames(flash_scene, frames),
                    _ => {
                        for &step in &mirror {
                            e.add_frame(
                                flash_scene,
                                sym,
                                1,
                                Some(ColorPair::new(Some(step), None)),
                                0,
                            )
                            .map_err(other)?;
                        }
                        if plain {
                            flash_memo.insert(sym, e.scenes.frames_of(flash_scene).to_vec());
                        }
                    }
                }
                for (a, &(_, circle)) in areas.iter().enumerate() {
                    let name = area_names[a];
                    let inside = &circles[circle as usize].inside;
                    let origin = inside[e.rng.choice_index(inside.len())];
                    let path = e
                        .path_new(slot, 0.4, Some(Easing::OutSine), None, 0, false, name)
                        .map_err(other)?;
                    e.path_new_waypoint(path, origin, None, name)
                        .map_err(other)?;
                    e.register_event(
                        slot,
                        Event::PathActivated,
                        Caller::Path(name),
                        Action::ActivateScene(FLASH_SCENE),
                    )
                    .map_err(other)?;
                    e.register_event(
                        slot,
                        Event::PathActivated,
                        Caller::Path(name),
                        Action::SetLayer(1),
                    )
                    .map_err(other)?;
                    e.register_event(
                        slot,
                        Event::PathComplete,
                        Caller::Path(name),
                        Action::DeactivateScene(None),
                    )
                    .map_err(other)?;
                    for inner in [3 * a + 1, 3 * a + 2] {
                        let next = inside[e.rng.choice_index(inside.len())];
                        let path = e
                            .path_new(
                                slot,
                                0.18,
                                Some(Easing::InOutSine),
                                None,
                                0,
                                false,
                                Name::auto(inner),
                            )
                            .map_err(other)?;
                        e.path_new_waypoint(path, next, None, Name::auto(inner + 1))
                            .map_err(other)?;
                    }
                }
                // the landing path and scene
                let path = e
                    .path_new(
                        slot,
                        0.45,
                        Some(Easing::InOutQuad),
                        None,
                        0,
                        false,
                        Name::NONE,
                    )
                    .map_err(other)?;
                e.path_new_waypoint(path, input, None, Name::NONE)
                    .map_err(other)?;
                let land_scene = e.scene_new(slot, Name::NONE, false, None, None);
                if dynamic {
                    let (fg, bg) = (e.input_fg(slot), e.input_bg(slot));
                    if fg.is_none() && bg.is_none() {
                        for step in flash_spectrum(dynamic_clear_color)? {
                            e.add_frame(
                                land_scene,
                                sym,
                                3,
                                Some(ColorPair::new(Some(step), None)),
                                0,
                            )
                            .map_err(other)?;
                        }
                        e.add_frame(land_scene, sym, 3, Some(ColorPair::default()), 0)
                            .map_err(other)?;
                    } else {
                        let fg = fg.map(flash_spectrum).transpose()?;
                        let bg = bg.map(flash_spectrum).transpose()?;
                        e.apply_gradient(land_scene, &[sym], 3, fg.as_deref(), bg.as_deref())
                            .map_err(other)?;
                    }
                } else {
                    let final_fg = *final_gradient_mapping
                        .get(&input)
                        .expect("gradient mapping fg");
                    let plain = e.scene(land_scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                    match land_memo.get(&(sym, final_fg)) {
                        Some(frames) if plain => e.append_frames(land_scene, frames),
                        _ => {
                            let spectrum = match land_spectra.entry(final_fg) {
                                Entry::Occupied(o) => o.into_mut(),
                                Entry::Vacant(v) => v.insert(flash_spectrum(final_fg)?),
                            };
                            for &step in spectrum.iter() {
                                e.add_frame(
                                    land_scene,
                                    sym,
                                    3,
                                    Some(ColorPair::new(Some(step), None)),
                                    0,
                                )
                                .map_err(other)?;
                            }
                            if plain {
                                land_memo.insert(
                                    (sym, final_fg),
                                    e.scenes.frames_of(land_scene).to_vec(),
                                );
                            }
                        }
                    }
                }
                e.register_event(
                    slot,
                    Event::PathComplete,
                    Caller::Path(landing),
                    Action::ActivateScene(LAND_SCENE),
                )
                .map_err(other)?;
                e.register_event(
                    slot,
                    Event::PathComplete,
                    Caller::Path(landing),
                    Action::SetLayer(0),
                )
                .map_err(other)?;
                e.register_event(
                    slot,
                    Event::PathActivated,
                    Caller::Path(landing),
                    Action::ActivateScene(FLASH_SCENE),
                )
                .map_err(other)?;
                e.chain_paths(slot, &chain, false).map_err(other)?;
            }
        }
        self.order = order;
        self.pending = bounds.len();
        self.bounds = bounds;
        self.call_next = true;
        self.active_digit = 0;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.pending == 0 && e.active_is_empty() {
            return false;
        }
        if self.pending != 0 && self.call_next {
            // the next swarm (from the end) takes off for its first area
            self.call_next = false;
            self.pending -= 1;
            self.current = self.bounds[self.pending];
            self.current_areas = self.areas[self.pending];
            self.active_digit = 0;
            for i in self.current.0..self.current.1 {
                let slot = *self.order.at(i);
                let area0 = *self.first_path.at(i);
                e.activate_path(self, slot, area0);
                e.set_visible(slot, true);
                e.active_insert(slot);
            }
        }
        let (start, end) = self.current;
        if e.active_count() < end - start {
            // some of the characters have landed
            self.call_next = true;
        }
        // the first character to reach a later swarm area (its active path is
        // area a = rel / 3, with a greater leading digit) leads the others
        let paths = 3 * self.current_areas;
        for i in start..end {
            let slot = *self.order.at(i);
            // NONE wraps far past `paths`
            let rel = e.ch.path.at(slot).wrapping_sub(*self.first_path.at(i));
            if rel >= paths || rel % 3 != 0 {
                continue;
            }
            let a = rel / 3;
            let digit = *self.digits.at(a);
            if digit <= self.active_digit {
                continue;
            }
            self.active_digit = digit;
            let coordination = self.config.swarm_coordination;
            for j in start..end {
                let other = *self.order.at(j);
                if other != slot && e.rng.random() < coordination {
                    let path = *self.first_path.at(j) + 3 * a;
                    e.activate_path(self, other, path);
                }
            }
            break;
        }
        e.update(self);
        true
    }
}
