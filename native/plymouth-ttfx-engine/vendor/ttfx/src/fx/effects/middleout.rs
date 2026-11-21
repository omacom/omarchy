//! middleout on the fx engine (old engine: effects/middleout.rs).
//!
//! Every character starts at the canvas center in the starting color and rides
//! an auto-named path to the center line. Once all have settled, each one (in
//! ascending slot order, the canonical set order) takes the "full" path home
//! while the "full" scene fades it from the starting color to its final color.
//! A scene's frames are memoized by (symbol, final color). No RNG draws.

use std::collections::HashMap;

use crate::effects::middleout::{ExpandDirection, MiddleoutConfig};
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SceneId, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{At, Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

pub struct Middleout {
    config: MiddleoutConfig,
    /// (slot, "full" path, "full" scene) in ascending slot order
    full: Vec<(u32, u32, SceneId)>,
    center_phase: bool,
}

impl Middleout {
    pub fn new(config: MiddleoutConfig) -> Self {
        Middleout {
            config,
            full: Vec::new(),
            center_phase: true,
        }
    }
}

impl Hooks for Middleout {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Middleout {
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
        let start = config.starting_color;
        let spectrum = |c: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[start, c], 10, false)
                .map_err(other)?
                .spectrum)
        };
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let full = e.name("full");
        let start_colors = ColorPair::new(Some(start), None);
        // (symbol, final color) -> the frames of a plain scene
        let mut memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        self.full.reserve(characters.len());
        for &slot in &characters {
            let input = e.input_coord(slot);
            let sym = e.input_sym(slot);
            e.set_coordinate(slot, canvas.center);
            let line = match config.expand_direction {
                ExpandDirection::Vertical => Coord::new(input.column, canvas.center_row),
                ExpandDirection::Horizontal => Coord::new(canvas.center_column, input.row),
            };
            let center_path = e
                .path_new(
                    slot,
                    config.center_movement_speed,
                    Some(config.center_easing),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(center_path, line, None, Name::NONE)
                .map_err(other)?;
            let full_path = e
                .path_new(
                    slot,
                    config.full_movement_speed,
                    Some(config.full_easing),
                    None,
                    0,
                    false,
                    full,
                )
                .map_err(other)?;
            e.path_new_waypoint(full_path, input, None, full)
                .map_err(other)?;
            let scene = e.scene_new(slot, full, false, None, None);
            if dynamic {
                let fg = e.input_fg(slot).map(spectrum).transpose()?;
                let bg = e.input_bg(slot).map(spectrum).transpose()?;
                if fg.is_some() || bg.is_some() {
                    e.apply_gradient(scene, &[sym], 6, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    e.add_frame(scene, sym, 6, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            } else {
                let final_fg = *final_gradient_mapping
                    .get(&input)
                    .expect("gradient mapping fg");
                let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match memo.get(&(sym, final_fg)) {
                    Some(frames) if plain => e.append_frames(scene, frames),
                    _ => {
                        e.apply_gradient(scene, &[sym], 6, Some(&spectrum(final_fg)?), None)
                            .map_err(other)?;
                        if plain {
                            memo.insert((sym, final_fg), e.scenes.frames_of(scene).to_vec());
                        }
                    }
                }
            }
            e.activate_path(self, slot, center_path);
            e.set_appearance(slot, Some(sym), Some(start_colors));
            e.set_visible(slot, true);
            e.active_insert(slot);
            self.full.push((slot, full_path, scene));
        }
        // the full phase activates in ascending slot order
        self.full.sort_unstable_by_key(|&(slot, _, _)| slot);
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if self.center_phase && e.active_is_empty() {
            self.center_phase = false;
            let full = std::mem::take(&mut self.full);
            for i in 0..full.len() {
                let (slot, path, scene) = *full.at(i);
                e.active_insert(slot);
                e.activate_path(self, slot, path);
                e.activate_scene(self, slot, scene);
            }
            self.full = full;
        }
        if e.active_is_empty() {
            return false;
        }
        e.update(self);
        true
    }
}
