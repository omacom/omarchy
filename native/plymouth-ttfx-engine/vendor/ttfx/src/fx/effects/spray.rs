//! spray on the fx engine (old engine: effects/spray.rs).
//!
//! Every character starts at the spray origin on one eased path to its input
//! coordinate (layer 1 while moving, 0 on arrival) and plays a 7-frame
//! droplet scene from a random final-spectrum color to its own final color.
//! The pending characters are shuffled and released a random handful per
//! frame. RNG draws happen in the old engine's order: per character the speed,
//! then the droplet's start color; then the shuffle. Droplet spectra are
//! memoized by (start index, final color) and their visuals by
//! (symbol, color).

use std::collections::HashMap;

use crate::effects::spray::{SprayConfig, SprayPosition};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::Frame;
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Visual, NONE};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, Gradient};
use crate::utils::pycompat::floor_div;

pub struct Spray {
    config: SprayConfig,
    pending: Vec<u32>,
    volume: i64,
}

impl Spray {
    pub fn new(config: SprayConfig) -> Self {
        Spray {
            config,
            pending: Vec::new(),
            volume: 1,
        }
    }
}

impl Hooks for Spray {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Spray {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
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
        let origin = match config.spray_position {
            SprayPosition::Center => canvas.center,
            SprayPosition::N => Coord::new(floor_div(canvas.right, 2), canvas.top),
            SprayPosition::Nw => Coord::new(canvas.left, canvas.top),
            SprayPosition::W => Coord::new(canvas.left, floor_div(canvas.top, 2)),
            SprayPosition::Sw => Coord::new(canvas.left, canvas.bottom),
            SprayPosition::S => Coord::new(floor_div(canvas.right, 2), canvas.bottom),
            SprayPosition::Se => Coord::new(canvas.right - 1, canvas.bottom),
            SprayPosition::E => Coord::new(canvas.right - 1, floor_div(canvas.top, 2)),
            SprayPosition::Ne => Coord::new(canvas.right - 1, canvas.top),
        };
        let (speed_min, speed_max) = config.movement_speed_range;
        let spectrum = &final_gradient.spectrum;
        // Droplet colors get ids: (start index, final color) -> the ids of
        // Gradient::with_steps([start, final], 7)'s spectrum, and per symbol
        // the visual of each color id (NONE until made)
        let mut colors: Vec<Color> = Vec::new();
        let mut color_ids: HashMap<Color, u32, FxBuild> = HashMap::default();
        let mut droplets: HashMap<(usize, Color), Vec<u32>, FxBuild> = HashMap::default();
        let mut visuals: Vec<Vec<Visual>> = Vec::new();
        let mut frames: Vec<Frame> = Vec::with_capacity(8);

        // TopToBottomLeftToRight draws nothing
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        e.scenes.reserve(characters.len(), characters.len() * 8);
        self.pending.reserve(characters.len());
        for &slot in &characters {
            let input = e.input_coord(slot);
            let sym = e.input_sym(slot);
            let speed = e.rng.uniform(speed_min, speed_max);
            e.set_coordinate(slot, origin);
            let path = e
                .path_new(
                    slot,
                    speed,
                    Some(config.movement_easing),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, input, None, Name::NONE)
                .map_err(other)?;
            let path_name = e.paths.recs[path as usize].name;
            e.register_event(
                slot,
                Event::PathActivated,
                Caller::Path(path_name),
                Action::SetLayer(1),
            )
            .map_err(other)?;
            e.register_event(
                slot,
                Event::PathComplete,
                Caller::Path(path_name),
                Action::SetLayer(0),
            )
            .map_err(other)?;

            let scene = e.scene_new(slot, Name::NONE, false, None, None);
            frames.clear();
            if dynamic {
                let info = VisualInfo {
                    sym,
                    fg: e.input_fg(slot),
                    bg: e.input_bg(slot),
                    attrs: HAS_COLORS,
                };
                let visual = e.visuals.make(&e.symbols, info);
                frames.resize(
                    7,
                    Frame {
                        visual,
                        duration: 20,
                    },
                );
            } else {
                let start = e.rng.choice_index(spectrum.len());
                let final_fg = *final_gradient_mapping
                    .get(&input)
                    .expect("gradient mapping fg");
                let ids = match droplets.get(&(start, final_fg)) {
                    Some(ids) => ids,
                    None => {
                        let gradient = Gradient::with_steps(&[spectrum[start], final_fg], 7, false)
                            .map_err(other)?;
                        let ids = gradient
                            .spectrum
                            .iter()
                            .map(|&c| {
                                *color_ids.entry(c).or_insert_with(|| {
                                    colors.push(c);
                                    colors.len() as u32 - 1
                                })
                            })
                            .collect();
                        droplets.entry((start, final_fg)).or_insert(ids)
                    }
                };
                if visuals.len() <= sym.0 as usize {
                    visuals.resize(sym.0 as usize + 1, Vec::new());
                }
                let table = &mut visuals[sym.0 as usize];
                if table.is_empty() {
                    // apply_gradient_to_symbols' check
                    let symbol = e.symbol(sym);
                    if symbol.chars().nth(1).is_some() {
                        return Err(other(format!(
                            "Symbol must be a string with a length of 1. Received: `{symbol}`."
                        )));
                    }
                }
                if table.len() < colors.len() {
                    table.resize(colors.len(), Visual(NONE));
                }
                for &id in ids {
                    let visual = table.at_mut(id);
                    if visual.0 == NONE {
                        let info = VisualInfo {
                            sym,
                            fg: Some(*colors.at(id)),
                            bg: None,
                            attrs: HAS_COLORS,
                        };
                        *visual = e.visuals.make(&e.symbols, info);
                    }
                    frames.push(Frame {
                        visual: *visual,
                        duration: 20,
                    });
                }
            }
            e.add_frames_visual(scene, &frames).map_err(other)?;
            e.activate_scene(self, slot, scene);
            e.activate_path(self, slot, path);
            self.pending.push(slot);
        }
        e.rng.shuffle(&mut self.pending);
        self.volume = ((self.pending.len() as f64 * config.spray_volume) as i64).max(1);
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.pending.is_empty() && e.active_is_empty() {
            return false;
        }
        if !self.pending.is_empty() {
            for _ in 0..e.rng.randint(1, self.volume) {
                if let Some(slot) = self.pending.pop() {
                    e.set_visible(slot, true);
                    e.active_insert(slot);
                }
            }
        }
        e.update(self);
        true
    }
}
