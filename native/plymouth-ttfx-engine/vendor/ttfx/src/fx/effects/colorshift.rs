//! colorshift on the fx engine (old engine: effects/colorshift.rs).
//!
//! Every character plays its "gradient" scene - the gradient's spectrum
//! rotated by its position - `cycles` times (the loop tracker callback
//! re-activates it on SCENE_COMPLETE), then "final_gradient". No RNG is
//! drawn. Gradient visuals are memoized by (symbol, spectrum index), so a
//! character's gradient scene is one bulk append.

use std::collections::hash_map::Entry;
use std::collections::HashMap;

use crate::effects::colorshift::ColorShiftConfig;
use crate::engine::animation::ExistingColorHandling;
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::events::{Action, Caller, Event};
use crate::fx::run::Effect;
use crate::fx::scene::Frame;
use crate::fx::visual::{VisualInfo, HAS_COLORS};
use crate::fx::{Engine, FxBuild, Hooks, Sym, Visual, NONE};
use crate::utils::geometry;
use crate::utils::graphics::{Color, ColorPair, Gradient, GradientDirection};

pub struct ColorShift {
    config: ColorShiftConfig,
    /// Per slot: loop_tracker_map's count, and the two scenes.
    loops: Vec<i64>,
    gradient_scene: Vec<u32>,
    final_scene: Vec<u32>,
}

impl ColorShift {
    pub fn new(config: ColorShiftConfig) -> Self {
        ColorShift {
            config,
            loops: Vec::new(),
            gradient_scene: Vec::new(),
            final_scene: Vec::new(),
        }
    }
}

impl Hooks for ColorShift {
    /// ColorShiftIterator.loop_tracker.
    fn callback(&mut self, e: &mut Engine, slot: u32, _id: u32, _arg: i64) {
        let count = &mut self.loops[slot as usize];
        *count += 1;
        if self.config.cycles == 0 || *count < self.config.cycles {
            let scene = self.gradient_scene[slot as usize];
            e.activate_scene(self, slot, scene);
        } else if !self.config.skip_final_gradient {
            let scene = self.final_scene[slot as usize];
            e.activate_scene(self, slot, scene);
        }
    }
}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for ColorShift {
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
        let gradient = Gradient::new(
            &config.gradient_stops,
            &config.gradient_steps,
            false,
            !config.no_loop,
        )
        .map_err(other)?;
        let spectrum = &gradient.spectrum;
        let len = spectrum.len();
        let dynamic = e.existing_color_handling() == ExistingColorHandling::Dynamic;
        let gradient_name = e.name("gradient");
        let final_name = e.name("final_gradient");
        let frames = config.gradient_frames;
        let slots = e.char_count();
        self.loops = vec![0; slots];
        self.gradient_scene = vec![NONE; slots];
        self.final_scene = vec![NONE; slots];

        // (symbol, spectrum index) -> visual, NONE until made
        let mut memo: HashMap<Sym, Vec<Visual>, FxBuild> = HashMap::default();
        // (rotation, final color) -> Gradient::with_steps([last, final], 8)
        let mut final_spectra: HashMap<(usize, Color), Vec<Color>, FxBuild> =
            HashMap::with_capacity_and_hasher(slots.min(1 << 14), FxBuild::default());
        let mut final_frames: Vec<Frame> = Vec::new();
        let mut scene_frames: Vec<Frame> = Vec::with_capacity(len);
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            e.set_visible(slot, true);
            let input_coord = e.input_coord(slot);
            // the colors start at spectrum[k]: Python's spectrum[shift:] +
            // spectrum[:shift]
            let k = if config.no_travel {
                0
            } else {
                let direction_index = match config.travel_direction {
                    GradientDirection::Horizontal => {
                        input_coord.column as f64 / canvas.right as f64
                    }
                    GradientDirection::Vertical => input_coord.row as f64 / canvas.top as f64,
                    GradientDirection::Diagonal => {
                        (input_coord.row + input_coord.column) as f64
                            / (canvas.right + canvas.top) as f64
                    }
                    GradientDirection::Radial => geometry::find_normalized_distance_from_center(
                        canvas.text_bottom,
                        canvas.text_top,
                        canvas.text_left,
                        canvas.text_right,
                        input_coord,
                    )
                    .map_err(other)?,
                };
                // int() truncation
                let mut shift_distance = (len as f64 * direction_index) as i64;
                if config.reverse_travel_direction {
                    shift_distance *= -1;
                }
                let k = if shift_distance < 0 {
                    (len as i64 + shift_distance).max(0) as usize
                } else {
                    shift_distance.min(len as i64) as usize
                };
                if k == len {
                    0
                } else {
                    k
                }
            };
            let sym = e.input_sym(slot);
            let scene = e.scene_new(slot, gradient_name, false, None, None);
            let visuals = memo.entry(sym).or_insert_with(|| vec![Visual(NONE); len]);
            scene_frames.clear();
            for i in (k..len).chain(0..k) {
                let visual = &mut visuals[i];
                if visual.0 == NONE {
                    let info = VisualInfo {
                        sym,
                        fg: Some(spectrum[i]),
                        bg: None,
                        attrs: HAS_COLORS,
                    };
                    *visual = e.visuals.make(&e.symbols, info);
                }
                scene_frames.push(Frame {
                    visual: *visual,
                    duration: frames as u32,
                });
            }
            e.add_frames_visual(scene, &scene_frames).map_err(other)?;
            let final_scene = e.scene_new(slot, final_name, false, None, None);
            self.gradient_scene[slot as usize] = scene;
            self.final_scene[slot as usize] = final_scene;
            let last_color = spectrum[(k + len - 1) % len];
            let pair = |c: Color| -> Result<Vec<Color>, EngineError> {
                Ok(Gradient::with_steps(&[last_color, c], 8, false)
                    .map_err(other)?
                    .spectrum)
            };
            if dynamic {
                let fg = e.input_fg(slot).map(pair).transpose()?;
                let bg = e.input_bg(slot).map(pair).transpose()?;
                if fg.is_some() || bg.is_some() {
                    e.apply_gradient(final_scene, &[sym], frames, fg.as_deref(), bg.as_deref())
                        .map_err(other)?;
                } else {
                    e.add_frame(final_scene, sym, frames, Some(ColorPair::default()), 0)
                        .map_err(other)?;
                }
            } else {
                let final_color = *final_gradient_mapping.get(&input_coord).unwrap();
                let spectrum = match final_spectra.entry((k, final_color)) {
                    Entry::Occupied(entry) => entry.into_mut(),
                    Entry::Vacant(entry) => entry.insert(pair(final_color)?),
                };
                // add_frame's visuals, appended at once
                final_frames.clear();
                for &color in spectrum.iter() {
                    let info = VisualInfo {
                        sym,
                        fg: Some(color),
                        bg: None,
                        attrs: HAS_COLORS,
                    };
                    final_frames.push(Frame {
                        visual: e.visuals.make(&e.symbols, info),
                        duration: frames as u32,
                    });
                }
                e.add_frames_visual(final_scene, &final_frames)
                    .map_err(other)?;
            }
            e.activate_scene(self, slot, scene);
            e.active_insert(slot);
            e.register_event(
                slot,
                Event::SceneComplete,
                Caller::Scene(gradient_name),
                Action::Callback(0, 0),
            )
            .map_err(other)?;
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
