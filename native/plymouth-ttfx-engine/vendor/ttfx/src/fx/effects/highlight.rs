//! highlight on the fx engine (old engine: effects/highlight.rs).
//!
//! Every character gets one "highlight" scene: its base color running up to
//! the brightened color and back. The groups in highlight direction are eased
//! in (InOutCirc over 100 steps), each activating its members' scenes. No RNG
//! is drawn. The highlight spectrum is remembered for the last base color and
//! a scene's frames by (symbol, base color, bg), so most characters' scenes
//! are one bulk append.

use std::collections::HashMap;

use crate::effects::highlight::HighlightConfig;
use crate::engine::animation::{Animation, ExistingColorHandling};
use crate::engine::error::EngineError;
use crate::engine::terminal::{CharacterFilter, CharacterSort};
use crate::fx::run::Effect;
use crate::fx::scene::{Frame, SCF_PREEXISTING, SCF_PRE_BOLD};
use crate::fx::visual::{color_key, VisualInfo, HAS_COLORS};
use crate::fx::{At, Engine, FxBuild, Hooks, NONE};
use crate::utils::easing::{Easing, EasingTracker};
use crate::utils::graphics::{Color, ColorPair, Gradient};

const FRAME_DURATION: u32 = 2;

pub struct Highlight {
    config: HighlightConfig,
    /// The groups in highlight direction, flattened: group g is
    /// `members[starts[g]..starts[g + 1]]`.
    members: Vec<u32>,
    starts: Vec<u32>,
    /// SequenceEaser over the groups.
    easer: EasingTracker,
    /// Per slot: its highlight scene.
    scene: Vec<u32>,
}

impl Highlight {
    pub fn new(config: HighlightConfig) -> Self {
        Highlight {
            config,
            members: Vec::new(),
            starts: Vec::new(),
            easer: EasingTracker::new(Easing::InOutCirc, 100, true),
            scene: Vec::new(),
        }
    }
}

impl Hooks for Highlight {}

fn other(message: String) -> EngineError {
    EngineError::Other(message)
}

impl Effect for Highlight {
    fn build(&mut self, e: &mut Engine) -> Result<(), EngineError> {
        let config = self.config.clone();
        let groups =
            e.get_characters_grouped(CharacterFilter::default(), config.highlight_direction);
        self.starts.clear();
        self.members.clear();
        self.starts.push(0);
        for group in &groups {
            self.members.extend_from_slice(group);
            self.starts.push(self.members.len() as u32);
        }

        let canvas = &e.canvas;
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
        let name = e.name("highlight");
        self.scene = vec![NONE; e.char_count()];
        // the highlight spectrum of the last base color
        let mut last_base: Option<Color> = None;
        let mut spectrum: Vec<Color> = Vec::new();
        // (symbol, base color, bg) -> frames[start..end] of a plain scene
        // (colors by color_key)
        let mut memo: HashMap<[u64; 3], (u32, u32), FxBuild> =
            HashMap::with_capacity_and_hasher(e.char_count().min(1 << 14), FxBuild::default());
        let mut frames: Vec<Frame> = Vec::new();
        let characters = e.get_characters(
            CharacterFilter::default(),
            CharacterSort::TopToBottomLeftToRight,
        );
        for slot in characters {
            let sym = e.input_sym(slot);
            let (base, bg) = if dynamic {
                (e.input_fg(slot), e.input_bg(slot))
            } else {
                (
                    Some(*final_gradient_mapping.get(&e.input_coord(slot)).unwrap()),
                    None,
                )
            };
            e.set_appearance(slot, Some(sym), Some(ColorPair::new(base, bg)));
            let scene = e.scene_new(slot, name, false, None, None);
            *self.scene.at_mut(slot) = scene;
            let plain = e.scene(scene).flags & (SCF_PREEXISTING | SCF_PRE_BOLD) == 0;
            if !plain {
                // preexisting colors replace every frame's own
                match base {
                    Some(base) => {
                        if last_base != Some(base) {
                            spectrum = highlight_spectrum(base, &config)?;
                            last_base = Some(base);
                        }
                        for &color in &spectrum {
                            e.add_frame(
                                scene,
                                sym,
                                FRAME_DURATION as i64,
                                Some(ColorPair::new(Some(color), bg)),
                                0,
                            )
                            .map_err(other)?;
                        }
                    }
                    None => {
                        e.add_frame(
                            scene,
                            sym,
                            FRAME_DURATION as i64,
                            Some(ColorPair::new(base, bg)),
                            0,
                        )
                        .map_err(other)?;
                    }
                }
            } else {
                let key = [sym.0 as u64, color_key(base), color_key(bg)];
                let (start, end) = match memo.get(&key) {
                    Some(&range) => range,
                    None => {
                        let start = frames.len() as u32;
                        let mut push = |e: &mut Engine, fg: Option<Color>| {
                            let visual = e.visuals.make(
                                &e.symbols,
                                VisualInfo {
                                    sym,
                                    fg,
                                    bg,
                                    attrs: HAS_COLORS,
                                },
                            );
                            frames.push(Frame {
                                visual,
                                duration: FRAME_DURATION,
                            });
                        };
                        match base {
                            Some(base) => {
                                if last_base != Some(base) {
                                    spectrum = highlight_spectrum(base, &config)?;
                                    last_base = Some(base);
                                }
                                for &color in &spectrum {
                                    push(e, Some(color));
                                }
                            }
                            None => push(e, None),
                        }
                        let range = (start, frames.len() as u32);
                        memo.insert(key, range);
                        range
                    }
                };
                e.add_frames_visual(scene, &frames[start as usize..end as usize])
                    .map_err(other)?;
            }
            e.set_visible(slot, true);
        }
        Ok(())
    }

    fn next_frame(&mut self, e: &mut Engine) -> bool {
        if e.active_is_empty() && self.easer.is_complete() {
            return false;
        }
        // SequenceEaser.step: the groups newly covered by the eased length
        let previous = self.easer.eased_value;
        let eased = self.easer.step();
        let count = self.starts.len() - 1;
        if count > 0 {
            let length = (eased * count as f64) as i64 as usize;
            let previous_length = (previous * count as f64) as i64 as usize;
            if length > previous_length {
                let first = *self.starts.at(previous_length);
                let last = *self.starts.at(length);
                for i in first..last {
                    let slot = *self.members.at(i);
                    let scene = *self.scene.at(slot);
                    e.activate_scene(self, slot, scene);
                    e.active_insert(slot);
                }
            }
        }
        e.update(self);
        true
    }
}

/// Gradient([base, bright, bright, base], [3, width, 3]), bright being the
/// base at the configured brightness.
fn highlight_spectrum(base: Color, config: &HighlightConfig) -> Result<Vec<Color>, EngineError> {
    let bright = Animation::adjust_color_brightness(&base, config.highlight_brightness);
    Ok(Gradient::new(
        &[base, bright, bright, base],
        &[3, config.highlight_width, 3],
        false,
        false,
    )
    .map_err(other)?
    .spectrum)
}
