//! scattered on the fx engine (old engine: effects/scattered.rs).
//!
//! Every character starts at a random canvas coordinate and travels to its
//! input coordinate on one eased path (layer 1 while moving, 0 on arrival)
//! while a distance-synced scene fades it from the first final-gradient color
//! to its own final color. A scene's frames are memoized by (symbol, final
//! color). The first 25 frames hold the scattered start without ticking. The
//! only RNG draws are the start coordinates, one per character in build order.

use std::collections::HashMap;

use crate::effects::scattered::ScatteredConfig;
use crate::engine::animation::{ExistingColorHandling, SyncMetric};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::geometry::Coord;
use crate::utils::graphics::{Color, ColorPair, Gradient};

const HOLD_FRAMES: u32 = 25;

pub struct Scattered {
    config: ScatteredConfig,
    hold: u32,
}

impl Scattered {
    pub fn new(config: ScatteredConfig) -> Self {
        Scattered { config, hold: 0 }
    }
}

impl Hooks for Scattered {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Scattered {
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
        let first = final_gradient.spectrum[0];
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let tiny = canvas.right < 2 || canvas.top < 2;
        // (symbol, final color) -> the frames of a plain scene
        let mut memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            let input = e.input_coord(slot);
            let sym = e.input_sym(slot);
            let start = if tiny {
                Coord::new(1, 1)
            } else {
                canvas.random_coord(&mut e.rng, false, false)
            };
            e.set_coordinate(slot, start);
            let path = e
                .path_new(
                    slot,
                    config.movement_speed,
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
            e.activate_path(self, slot, path);
            e.set_visible(slot, true);
            let scene = e.scene_new(slot, Name::NONE, false, Some(SyncMetric::Distance), None);
            if dynamic {
                let colors = ColorPair::new(e.input_fg(slot), e.input_bg(slot));
                e.add_frame(scene, sym, config.final_gradient_frames, Some(colors), 0)
                    .map_err(other)?;
            } else {
                let final_fg = *final_gradient_mapping
                    .get(&input)
                    .expect("gradient mapping fg");
                let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
                match memo.get(&(sym, final_fg)) {
                    Some(frames) if plain => e.append_frames(scene, frames),
                    _ => {
                        let spectrum = Gradient::with_steps(&[first, final_fg], 10, false)
                            .map_err(other)?
                            .spectrum;
                        e.apply_gradient(
                            scene,
                            &[sym],
                            config.final_gradient_frames,
                            Some(&spectrum),
                            None,
                        )
                        .map_err(other)?;
                        if plain {
                            memo.insert((sym, final_fg), e.scenes.frames_of(scene).to_vec());
                        }
                    }
                }
            }
            e.activate_scene(self, slot, scene);
            e.active_insert(slot);
        }
        self.hold = HOLD_FRAMES;
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if e.active_is_empty() {
            return false;
        }
        if self.hold != 0 {
            self.hold -= 1;
            return true;
        }
        e.update(self);
        true
    }
}
