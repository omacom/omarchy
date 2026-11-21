//! expand on the fx engine (old engine: effects/expand.rs).
//!
//! Every character starts at the canvas center and travels to its input
//! coordinate on one eased path (layer 1 while moving, 0 on arrival) while a
//! distance-synced scene fades it from the first final-gradient color to its
//! own final color. A scene's frames are memoized by (symbol, final color).
//! No RNG draws.

use std::collections::HashMap;

use crate::effects::expand::ExpandConfig;
use crate::engine::animation::{ExistingColorHandling, SyncMetric};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::{Engine, FxBuild, Hooks, Name, Sym};
use crate::utils::graphics::{Color, ColorPair, Gradient};

pub struct Expand {
    config: ExpandConfig,
}

impl Expand {
    pub fn new(config: ExpandConfig) -> Self {
        Expand { config }
    }
}

impl Hooks for Expand {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Expand {
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
        let spectrum = |c: Color| -> Result<Vec<Color>, EngineError> {
            Ok(Gradient::with_steps(&[first, c], 10, false)
                .map_err(other)?
                .spectrum)
        };
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        // (symbol, final color) -> the frames of a plain scene
        let mut memo: HashMap<(Sym, Color), Vec<Frame>, FxBuild> = HashMap::default();
        // both of the old engine's passes use TopToBottomLeftToRight, which
        // draws nothing; the first only fills the final color map
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            let input = e.input_coord(slot);
            let sym = e.input_sym(slot);
            e.set_coordinate(slot, canvas.center);
            let path = e
                .path_new(
                    slot,
                    config.movement_speed,
                    Some(config.expand_easing),
                    None,
                    0,
                    false,
                    Name::NONE,
                )
                .map_err(other)?;
            e.path_new_waypoint(path, input, None, Name::NONE)
                .map_err(other)?;
            let path_name = e.paths.recs[path as usize].name;
            e.set_visible(slot, true);
            e.active_insert(slot);
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
            let scene = e.scene_new(slot, Name::NONE, false, Some(SyncMetric::Distance), None);
            if dynamic {
                let fg = e.input_fg(slot).map(spectrum).transpose()?;
                let bg = e.input_bg(slot).map(spectrum).transpose()?;
                if fg.is_some() || bg.is_some() {
                    e.apply_gradient(scene, &[sym], 1, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    e.add_frame(scene, sym, 1, Some(ColorPair::default()), 0)
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
                        e.apply_gradient(scene, &[sym], 5, Some(&spectrum(final_fg)?), None)
                            .map_err(other)?;
                        if plain {
                            memo.insert((sym, final_fg), e.scenes.frames_of(scene).to_vec());
                        }
                    }
                }
            }
            e.activate_scene(self, slot, scene);
        }
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if e.active_is_empty() {
            return false;
        }
        e.update(self);
        true
    }
}
