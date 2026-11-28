//! fireworks on the fx engine (old engine: effects/fireworks.rs).
//!
//! The old engine's shells are consecutive runs of the top-to-bottom order:
//! shell 0 is always empty (the loop pushes the empty accumulator at the first
//! boundary) and shell k >= 1 holds characters [(k - 1) * volume, k * volume).
//! They launch from the last one down, the empty shell last, and every launch
//! draws the next delay, so only the count of shells left is kept.
//!
//! Every character gets the apex, explode (auto id) and input paths chained by
//! PATH_COMPLETE, then a looping launch scene, a step-synced bloom scene and
//! the fall scene. Scene frames are memoized by (symbol, shell color[, final
//! color]).

use std::collections::hash_map::Entry;
use std::collections::HashMap;

use crate::effects::fireworks::FireworksConfig;
use crate::engine::animation::{ExistingColorHandling, SyncMetric};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::easing::Easing;
use crate::utils::geometry::{extrapolate_along_ray, find_coords_in_circle, Coord};
use crate::utils::graphics::{Color, ColorPair, Gradient};
use crate::utils::pycompat::{floor_div, round_half_even};

pub struct Fireworks {
    config: FireworksConfig,
    /// The input characters, top to bottom.
    order: Vec<u32>,
    volume: usize,
    /// Shells not launched yet (the empty shell 0 included).
    shells: usize,
    delay: i64,
}

impl Fireworks {
    pub fn new(config: FireworksConfig) -> Self {
        Fireworks {
            config,
            order: Vec::new(),
            volume: 1,
            shells: 0,
            delay: 0,
        }
    }

    /// The positions of shell `k` (>= 1) in `order`.
    #[inline]
    fn shell_range(&self, k: usize) -> std::ops::Range<usize> {
        let start = (k - 1) * self.volume;
        start..(start + self.volume).min(self.order.len())
    }
}

impl Hooks for Fireworks {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

fn is_plain(e: &Engine, scene: u32) -> bool {
    e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0
}

impl Effect for Fireworks {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let input_count = e.input_chars.len();
        self.volume = round_half_even(config.firework_volume * input_count as f64).max(1) as usize;
        let explode_distance =
            round_half_even(e.canvas.right as f64 * config.explode_distance).clamp(1, 15);
        self.delay = 0;

        // prepare_waypoints
        let apex = e.name("apex_pth");
        let input = e.name("input_pth");
        let fall = e.name("fall_scn");
        self.order = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        let order = std::mem::take(&mut self.order);
        self.shells = if order.is_empty() {
            0
        } else {
            order.len().div_ceil(self.volume) + 1
        };
        let canvas_bottom = e.canvas.bottom;
        let canvas_top = e.canvas.top;
        let canvas_right = e.canvas.right;
        let bloom_offset = floor_div(explode_distance, 2) as f64;
        let mut origin = Coord::new(0, 0);
        let mut circle: Vec<Coord> = Vec::new();
        for (i, &slot) in order.iter().enumerate() {
            if i % self.volume == 0 {
                let origin_x = e.rng.randrange(0, canvas_right);
                let min_row = if config.explode_anywhere {
                    canvas_bottom
                } else {
                    e.input_coord(slot).row
                };
                let origin_y = e.rng.randrange(min_row, canvas_top + 1);
                origin = Coord::new(origin_x, origin_y);
                circle = find_coords_in_circle(origin, explode_distance);
            }
            let input_coord = e.input_coord(slot);
            e.set_coordinate(slot, Coord::new(origin.column, canvas_bottom));
            let apex_path = e
                .path_new(slot, 0.35, Some(Easing::OutExpo), Some(2), 0, false, apex)
                .map_err(other)?;
            e.path_new_waypoint(apex_path, origin, None, Name::NONE)
                .map_err(other)?;
            let explode_speed = e.rng.uniform(0.2, 0.4);
            let explode_path = e
                .path_new(
                    slot,
                    explode_speed,
                    Some(Easing::OutCirc),
                    Some(2),
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            let explode_wpt = *e.rng.choice(&circle);
            e.path_new_waypoint(explode_path, explode_wpt, None, Name::NONE)
                .map_err(other)?;
            let control = extrapolate_along_ray(origin, explode_wpt, bloom_offset);
            let bloom_wpt = Coord::new(control.column, (control.row - 7).max(1));
            e.path_new_waypoint(explode_path, bloom_wpt, Some(&[control]), Name::NONE)
                .map_err(other)?;
            let input_path = e
                .path_new(
                    slot,
                    0.6,
                    Some(Easing::InOutQuart),
                    Some(2),
                    0,
                    false,
                    input,
                )
                .map_err(other)?;
            e.path_new_waypoint(
                input_path,
                input_coord,
                Some(&[Coord::new(bloom_wpt.column, 1)]),
                Name::NONE,
            )
            .map_err(other)?;
            let explode = e.paths.recs[explode_path as usize].name;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(apex),
                Action::ActivatePath(explode),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(explode),
                Action::ActivatePath(input),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(input),
                Action::SetLayer(0),
            )
            .map_err(other)?;
            e.activate_path(self, slot, apex_path);
        }

        // prepare_scenes
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
        let white = Color::from_hex("FFFFFF").unwrap();
        let firework_symbol = e.sym(&config.firework_symbol);
        let pair_spectrum = |a: Color, b: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[a, b], 15, false)
                .map_err(other)?
                .spectrum)
        };
        // shell color -> launch frames; (symbol, shell color) -> bloom frames;
        // (symbol, shell color, final color) -> fall frames (plain scenes only);
        // (shell color, final color) -> the fall spectrum
        let mut launch_memo: HashMap<Color, Vec<Frame>, FxBuild> = HashMap::default();
        let mut bloom_memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();
        let mut fall_memo: HashMap<(Sym, Color, Color), Vec<Frame>, FxBuild> = HashMap::default();
        let mut fall_spectra: HashMap<(Color, Color), Vec<Color>, FxBuild> = HashMap::default();
        for k in 0..self.shells {
            let shell_color = *e.rng.choice(&config.firework_colors);
            if k == 0 {
                continue;
            }
            let shell_spectrum = Gradient::with_steps(&[shell_color, white, shell_color], 5, false)
                .map_err(other)?
                .spectrum;
            let start = (k - 1) * self.volume;
            let end = (start + self.volume).min(order.len());
            for &slot in &order[start..end] {
                let sym = e.input_sym(slot);
                let launch = e.scene_new(slot, Name::NONE, true, None, None);
                let plain = is_plain(e, launch);
                match launch_memo.get(&shell_color) {
                    Some(frames) if plain => e.append_frames(launch, frames),
                    _ => {
                        let shell = Some(ColorPair::new(Some(shell_color), None));
                        e.add_frame(launch, firework_symbol, 2, shell, 0)
                            .map_err(other)?;
                        e.add_frame(
                            launch,
                            firework_symbol,
                            1,
                            Some(ColorPair::new(Some(white), None)),
                            0,
                        )
                        .map_err(other)?;
                        if plain {
                            launch_memo.insert(shell_color, e.scenes.frames_of(launch).to_vec());
                        }
                    }
                }
                let bloom = e.scene_new(slot, Name::NONE, false, Some(SyncMetric::Step), None);
                match bloom_memo.get(&(sym, shell_color)) {
                    Some(frames) if plain => e.append_frames(bloom, frames),
                    _ => {
                        for &color in &shell_spectrum {
                            e.add_frame(bloom, sym, 2, Some(ColorPair::new(Some(color), None)), 0)
                                .map_err(other)?;
                        }
                        if plain {
                            bloom_memo
                                .insert((sym, shell_color), e.scenes.frames_of(bloom).to_vec());
                        }
                    }
                }
                let fall_scene = e.scene_new(slot, fall, false, None, None);
                if dynamic {
                    let fg = e
                        .input_fg(slot)
                        .map(|c| pair_spectrum(shell_color, c))
                        .transpose()?;
                    let bg = e
                        .input_bg(slot)
                        .map(|c| pair_spectrum(shell_color, c))
                        .transpose()?;
                    if fg.is_some() || bg.is_some() {
                        e.apply_gradient(fall_scene, &[sym], 10, fg.as_deref(), bg.as_deref())
                            .map_err(other)?;
                    } else {
                        e.add_frame(fall_scene, sym, 10, Some(ColorPair::default()), 0)
                            .map_err(other)?;
                    }
                } else {
                    let final_fg = *final_gradient_mapping
                        .get(&e.input_coord(slot))
                        .expect("gradient mapping fg");
                    match fall_memo.get(&(sym, shell_color, final_fg)) {
                        Some(frames) if plain => e.append_frames(fall_scene, frames),
                        _ => {
                            let key = (shell_color, final_fg);
                            if let Entry::Vacant(v) = fall_spectra.entry(key) {
                                v.insert(pair_spectrum(shell_color, final_fg)?);
                            }
                            // apply_gradient_to_symbols([symbol], 10, spectrum)
                            for &color in &fall_spectra[&key] {
                                e.add_frame(
                                    fall_scene,
                                    sym,
                                    10,
                                    Some(ColorPair::new(Some(color), None)),
                                    0,
                                )
                                .map_err(other)?;
                            }
                            if plain {
                                fall_memo.insert(
                                    (sym, shell_color, final_fg),
                                    e.scenes.frames_of(fall_scene).to_vec(),
                                );
                            }
                        }
                    }
                }
                e.activate_scene(self, slot, launch);
                let bloom_name = e.scene_name(bloom);
                e.register_event(
                    slot,
                    Event::PathComplete,
                    Caller::Path(apex),
                    Action::ActivateScene(bloom_name),
                )
                .map_err(other)?;
                e.register_event(
                    slot,
                    Event::PathActivated,
                    Caller::Path(input),
                    Action::ActivateScene(fall),
                )
                .map_err(other)?;
            }
        }
        self.order = order;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.shells == 0 && e.active_is_empty() {
            return false;
        }
        if self.shells != 0 && self.delay <= 0 {
            self.shells -= 1;
            if self.shells != 0 {
                for i in self.shell_range(self.shells) {
                    let slot = self.order[i];
                    e.set_visible(slot, true);
                    e.active_insert(slot);
                }
            }
            // int(launch_delay * uniform(0.5, 1.5))
            self.delay = (self.config.launch_delay as f64 * e.rng.uniform(0.5, 1.5)) as i64;
        }
        self.delay -= 1;
        e.update(self);
        true
    }
}
